'use strict';

const AdmZip = require('adm-zip');
const async = require('async');
const AWS = require('aws-sdk');

const s3 = new AWS.S3();

const deleteSource = process.env.DELETE_SOURCE;
const destBucket = process.env.DEST_BUCKET;
const destPrefix = process.env.DEST_PREFIX;
const destKey = process.env.DEST_KEY;
const matchRegex = new RegExp(process.env.MATCH_REGEX);

exports.handler = function (event, context, callback) {
    const srcBucket = event.Records[0].s3.bucket.name;
    const srcKey = decodeURIComponent(event.Records[0].s3.object.key.replace(/\+/g, " "));
    const srcParts = srcKey.split('/');
    const zipFilename = srcParts[srcParts.length - 1].replace('.zip', '');

    async.waterfall([
        function download(next) {
            s3.getObject({
                Bucket: srcBucket,
                Key: srcKey
            }, next);
        },
        function unzip(response, next) {
            const zip = new AdmZip(response.Body);

            next(null, zip.getEntries());
        },
        function upload(files, next) {
            const uploads = files
                .filter(file => file.entryName.match(matchRegex))
                .map(file => {
                    let parts = file.entryName.split('/');
                    parts = parts[parts.length - 1].split('.');

                    const extension = parts.pop();
                    const filename = parts.join('.');

                    const key = destKey ?
                        destKey.replace('$zipFilename', zipFilename).replace('$filename', filename).replace('$extension', extension)
                        : file.entryName;

                    return s3.putObject({
                        Bucket: destBucket,
                        Key: destPrefix + key,
                        Body: file.getData()
                    }).promise();
                });

            Promise.all(uploads)
                .catch(error => next(error))
                .then(() => next());
        },
        function cleanup(next) {
            if (deleteSource === false) {
                return next();
            }

            s3.deleteObject({
                Bucket: srcBucket,
                Key: srcKey
            }, next);            
        }
    ], function (error) {
        if (error) {
            console.error(error);
        }

        callback(null);
    });
};

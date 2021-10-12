<?php

return [
    'bundles' => [
        'hw-xsj-tp' => [
            'driver' => 'qiniu',
            'config' => [
                'access_key' => "[[.qiniu_access_key]]",
                'secret_key' => "[[.qiniu_secret_key]]",
                'bucket' => 'hw-xsj-tp',
                'bucket_base_url' => 'https://zt-cdn.sgsdk.com',
                'callback_host' => '', 
                'callback_url' => "https://dev-zt.sgsdk.com/core/upload/qiniu_callback",
            ],
        ],
    ],
];

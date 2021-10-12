<?php

return [
    'prefix' => '__CACHE__',
    'default' => 'redis',
    'stores' => [
        'memcached' => [
            'driver' => 'memcached',
            'servers' => [
                [
                    'host' => "192.168.166.21",
                    'port' => "11212",
                    'weight' => 100,
                ],
            ],
        ],
        'redis' => [
            'driver' => 'redis',
            'connection' => 'default',
        ],
    ],
];

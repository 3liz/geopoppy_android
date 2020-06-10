
;<?php die(''); ?>
;for security reasons , don't remove or modify the first line

hideSensitiveServicesProperties=1

;Services
;list the different map services (servers, generic parameters, etc.)
[services]
;wmsServerURL="http://127.0.0.1:8080/ows/"
wmsServerURL="http://localhost:2081/qgisserver"
;List of URL available for the web client
onlyMaps=0
defaultRepository=
defaultProject=
cacheStorageType=file
;cacheStorageType=sqlite => store cached images in one sqlite file per repo/project/layer
;cacheStorageType=file => store cached images in one folder per repo/project/layer. The root folder is /tmp/
cacheRedisHost=localhost
cacheRedisPort=6379
cacheExpiration=0
cacheRedisDb=
cacheRedisKeyPrefix=
; default cache expiration : the default time to live of data, in seconds.
; 0 means no expiration, max : 2592000 seconds (30 days)
proxyMethod=php
; php -> use the built in file_get_contents method
; curl-> use curl. It must be installed.
debugMode=0
; debug mode
; on = print debug messages in lizmap/var/log/messages.log
; off = no lizmap debug messages
cacheRootDirectory="/tmp/"
; cache root directory where cache files will be stored
; must be writable
allowUserAccountRequests=off

; path to find repositories
rootRepositories="/storage/internal/geopoppy/qgis/"

; Use relative path
relativeWMSPath=true


[repository:demo]
label=demo
path="/storage/internal/geopoppy/qgis/demo/"
allowUserDefinedThemes=1


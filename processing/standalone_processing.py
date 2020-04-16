#!/usr/bin/env python3
import os, sys
import json

# init paths
# to be able to load processing.core.Processing
sys.path.append(os.path.join(os.environ.get('QGIS_PREFIX_PATH','/usr/'), "share/qgis/python/plugins/"))
# to be able to load lizsync plugins
sys.path.append('/home/mdouchin/.local/share/QGIS/QGIS3/profiles/default/python/plugins/')
# Initialize PostgreSQL service connection file PGSERVICEFILE
os.environ['PGSERVICEFILE'] = '/etc/postgresql-common/pg_service.conf'

# Import QGIS AND QT modules
from qgis.core import QgsSettings, QgsApplication
from qgis.analysis import QgsNativeAlgorithms
from qgis.PyQt.QtCore import QCoreApplication, QSettings
from processing.core.Processing import Processing

# Create QGIS app
qgisPrefixPath = os.environ.get('QGIS_PREFIX_PATH', '/usr/')
qgisConfigPath = os.environ.get('QGIS_CUSTOM_CONFIG_PATH', '/home/mdouchin/.local/share/QGIS/QGIS3/profiles/default/')

QgsApplication.setPrefixPath(qgisPrefixPath, True)
app = QgsApplication([], False, qgisConfigPath)

# Settings : needed so that db_manager plugin can read the settings from QGIS3.ini
QCoreApplication.setOrganizationName( QgsApplication.QGIS_ORGANIZATION_NAME )
QCoreApplication.setOrganizationDomain( QgsApplication.QGIS_ORGANIZATION_DOMAIN )
QCoreApplication.setApplicationName( QgsApplication.QGIS_APPLICATION_NAME )
QSettings.setDefaultFormat( QSettings.IniFormat )
QSettings.setPath( QSettings.IniFormat, QSettings.UserScope, qgisConfigPath )

# Init QGIS
app.initQgis()

# Initialize processing
Processing.initialize()

# Add native QGIS provider
reg = app.processingRegistry()

reg.addProvider(QgsNativeAlgorithms())

# Add lizsync provider
from lizsync.processing.provider import LizsyncProvider
reg.addProvider(LizsyncProvider())

# Get parameters
input_alg = sys.argv[1]
parameters = sys.argv[2]
input_params = json.loads(parameters)

# Run Alg
from qgis.core import QgsProcessingFeedback
feedback = QgsProcessingFeedback()
from processing import run as processing_run
res = processing_run(
    input_alg,
    input_params,
    feedback=feedback
)
print("RESULT = %s" % json.dumps(res))

# Exit
app.exitQgis()

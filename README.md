# DAACS-Install

DAACS Utility Repo. (WORK IN PROGRESS)

1 - Install system dependencies
2 - Install daacs command in path
3 - Create system users
4 - Create/Update/Refresh instance
5 - Reset service
6 - Reset all services in folder
7 - K6 - not working yet

Work in progress
K6 - load testing, and framework testing


MAX_LOGIN_SLEEP=1 ADMIN_CREDENTIALS="admin,password" HOST="https://papertowels.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="46997151-21a3-4eef-b657-e7dcdd913481" LOGGING_STATUS=1 K6_WEB_DASHBOARD=true K6_WEB_DASHBOARD_PERIOD=2s K6_WEB_DASHBOARD_EXPORT=html-report.html LOAD_TEST_TYPE_SPEED="fast" LOAD_TEST_TYPE_SCENRIO="stages-constant-vus" VUS=1 RUN_GET_PDF=true RUN_GET_ASSESSMENT_RESULTS=true DURATION="60s" INSECURE_SKIP_TLS="true" k6 run k6.assessment.loadtest.js --out json=k6.json


MAX_LOGIN_SLEEP=1 ADMIN_CREDENTIALS="admin,password" HOST="https://papertowels.victor.com" STUDENT_FILE="teststudents.csv" ASSESSMENT_ID="46997151-21a3-4eef-b657-e7dcdd913481" LOGGING_STATUS=1 K6_WEB_DASHBOARD=true K6_WEB_DASHBOARD_PERIOD=2s K6_WEB_DASHBOARD_EXPORT=html-report.html LOAD_TEST_TYPE_SPEED="fast" LOAD_TEST_TYPE_SCENRIO="stages-constant-vus" VUS=1 RUN_GET_PDF=true RUN_GET_ASSESSMENT_RESULTS=true INSECURE_SKIP_TLS="true" k6 run k6.assessment.loadtest.js --out json=k6.json

const { google } = require('googleapis');
const { GoogleAuth } = require('google-auth-library'); // Corrección aquí


exports.stopCloudSQLInstance = async (req, res) => {
    try {
        res.status(200).send('Función ejecutada con éxito.');
    } catch (error) {
        console.error('Error:', error);
        res.status(500).send('Error interno del servidor');
    }
};




// exports.stopCloudSQLInstance = async (req, res) => {
//     try {
//         // Autenticación
//         const auth = new GoogleAuth({
//             scopes: ['https://www.googleapis.com/auth/cloud-platform']
//         });
//         const authClient = await auth.getClient();

//         // Configurar Google Cloud SQL Admin
//         const sqladmin = google.sqladmin({
//             version: 'v1beta4',
//             auth: authClient
//         });

//         // Obtener el Project ID desde la cuenta de servicio
//         const projectId = await authClient.getProjectId();

//         // Obtener el Instance ID de Cloud SQL
//         const instanceId = 'my-wordpress-db'; // Reemplaza con tu ID de instancia

//         // Obtener el nombre del servicio de Cloud Run
//         const cloudRunService = 'my-wordpress-app'; // Reemplaza con el nombre de tu servicio

//         // Comprobar instancias activas de Cloud Run
//         const runClient = google.run({
//             version: 'v1',
//             auth: authClient
//         });

//         const serviceResponse = await runClient.namespaces.services.get({
//             name: `namespaces/${projectId}/services/${cloudRunService}`
//         });

//         const serviceInfo = serviceResponse.data;
//         if (serviceInfo.status.traffic[0].percent === 0) {
//             // Detener la instancia de Cloud SQL
//             await sqladmin.instances.patch({
//                 project: projectId,
//                 instance: instanceId,
//                 requestBody: {
//                     settings: {
//                         activationPolicy: 'NEVER'
//                     }
//                 }
//             });
//             res.status(200).send('Instancia de Cloud SQL apagada.');
//         } else {
//             res.status(200).send('Cloud Run sigue activo.');
//         }
//     } catch (error) {
//         console.error('Error:', error);
//         res.status(500).send('Error al procesar la solicitud');
//     }
// };



// const {google} = require('googleapis');

// exports.stopCloudSQLInstance = async (req, res) => {
//     const auth = new google.auth.GoogleAuth({
//         scopes: ['https://www.googleapis.com/auth/cloud-platform']
//     });
//     const projectId = 'wpdeploy';
//     const instanceId = 'my-wordpress-db';
//     const cloudRunService = 'my-wordpress-app';

//     const runClient = google.run({
//         version: 'v1',
//         auth: auth
//     });

//     // Comprobar instancias activas de Cloud Run
//     const serviceResponse = await runClient.namespaces.services.get({
//         name: `namespaces/${projectId}/services/${cloudRunService}`
//     });

//     const serviceInfo = serviceResponse.data;
//     if (serviceInfo.status.traffic[0].percent === 0) {
//         const sqladmin = google.sqladmin('v1beta4');
//         await sqladmin.instances.patch({
//             auth: auth,
//             project: projectId,
//             instance: instanceId,
//             requestBody: {
//                 settings: {
//                     activationPolicy: 'NEVER'
//                 }
//             }
//         });
//         res.send('Instancia de Cloud SQL apagada.');
//         console.log('Instancia de Cloud SQL apagada.');
//     } else {
//         res.send('Cloud Run sigue activo.');
//         console.log('Cloud Run sigue activo.');
//     }
// };



// const { google } = require('googleapis');
// const sqladmin = google.sqladmin('v1beta4');

// // Configura la autenticación de Google Cloud
// const auth = new google.auth.GoogleAuth({
//   scopes: ['https://www.googleapis.com/auth/cloud-platform']
// });

// // Parámetros de configuración
// const PROJECT_ID = process.env.GCP_PROJECT;
// const CLOUD_RUN_SERVICE_NAME = 'my-wordpress-app';
// const CLOUD_RUN_REGION = 'europe-southwest1';
// const CLOUD_SQL_INSTANCE_ID = 'my-wordpress-db';

// exports.checkAndStopSQL = async (req, res) => {
//   try {
//     const authClient = await auth.getClient();
//     google.options({ auth: authClient });

//     // Verificar el estado de Cloud Run
//     const run = google.run({
//       version: 'v1',
//       auth: authClient
//     });

//     const serviceName = `projects/${PROJECT_ID}/locations/${CLOUD_RUN_REGION}/services/${CLOUD_RUN_SERVICE_NAME}`;
//     const service = await run.projects.locations.services.get({ name: serviceName });
//     const serviceStatus = service.data.status;

//     if (serviceStatus && serviceStatus.traffic && serviceStatus.traffic.length > 0) {
//       // Verifica si hay tráfico
//       const activeInstances = serviceStatus.traffic.some(t => t.percent > 0);
//       if (!activeInstances) {
//         // Detener Cloud SQL
//         await sqladmin.instances.stop({
//           project: PROJECT_ID,
//           instance: CLOUD_SQL_INSTANCE_ID
//         });
//         console.log('Cloud SQL instance has been stopped due to inactivity.');
//         res.status(200).send('Cloud SQL instance stopped.');
//       } else {
//         console.log('Cloud Run service is active, no action taken.');
//         res.status(200).send('Cloud Run service is active, no action taken.');
//       }
//     } else {
//       console.log('No active instances found, stopping Cloud SQL instance.');
//       // Detener Cloud SQL
//       await sqladmin.instances.stop({
//         project: PROJECT_ID,
//         instance: CLOUD_SQL_INSTANCE_ID
//       });
//       res.status(200).send('Cloud SQL instance stopped.');
//     }
//   } catch (error) {
//     console.error('Error checking Cloud Run status or stopping Cloud SQL:', error);
//     res.status(500).send('Error processing your request.');
//   }
// };

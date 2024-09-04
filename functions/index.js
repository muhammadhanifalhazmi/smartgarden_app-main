const functions = require('firebase-functions');
const admin = require('firebase-admin');
const axios = require('axios');

admin.initializeApp();

exports.scheduledFunction = functions.pubsub.schedule('every 60 minutes').onRun(async (context) => {
  const db = admin.database();
  const now = new Date();
  const formattedDate = now.toISOString();

  try {
    // Mengambil data sensor dari endpoint API fiktif
    const response = await axios.get('https://api.example.com/sensor-data');
    const sensorData = response.data;

    const temperature = sensorData.temperature;
    const humidity = sensorData.humidity;
    const moisture = sensorData.moisture;

    await db.ref('logs/' + formattedDate).set({
      temperature: temperature,
      humidity: humidity,
      moisture: moisture,
    });

    console.log('Data berhasil disimpan:', { temperature, humidity, moisture });
  } catch (error) {
    console.error('Error mengambil atau menyimpan data sensor:', error);
  }

  return null;
});

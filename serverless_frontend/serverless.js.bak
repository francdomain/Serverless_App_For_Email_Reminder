// Updated API endpoint for Remindly
var API_ENDPOINT = 'api_url';

// Selecting message divs for notifications
var errorDiv = document.getElementById('error-message');
var successDiv = document.getElementById('success-message');
var resultsDiv = document.getElementById('results-message');

// Functions to retrieve input values
function waitSecondsValue() {
  return document.getElementById('waitSeconds').value;
}
function messageValue() {
  return document.getElementById('message').value;
}
function emailValue() {
  return document.getElementById('email').value;
}

// Clear notification messages
function clearNotifications() {
  errorDiv.textContent = '';
  resultsDiv.textContent = '';
  successDiv.textContent = '';
}

// Event listener for the "Send Email" button
document.getElementById('emailButton').addEventListener('click', function (e) {
  sendData(e, 'email');
});

// Function to send data to the API Gateway
function sendData(e, pref) {
  e.preventDefault(); // Prevent default form submission
  clearNotifications(); // Clear previous messages
  fetch(API_ENDPOINT, {
    headers: {
      "Content-type": "application/json"
    },
    method: 'POST',
    body: JSON.stringify({
      waitSeconds: waitSecondsValue(),
      message: messageValue(),
      email: emailValue()
    }),
    mode: 'cors'
  })
    .then((resp) => resp.json())
    .then(function (data) {
      console.log(data);
      successDiv.textContent = 'Submitted successfully! Check the result below.';
      resultsDiv.textContent = JSON.stringify(data);
    })
    .catch(function (err) {
      errorDiv.textContent = 'Oops! An error occurred:\n' + err.toString();
      console.log(err);
    });
};
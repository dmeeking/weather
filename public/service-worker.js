'use strict';


function openDB()
{
  return new Promise(function(resolve, reject) {

    var openRequest = indexedDB.open("userTokens",1);
    openRequest.onupgradeneeded = function(e) {
      var thisDB = e.target.result;

      if(!thisDB.objectStoreNames.contains("tokens")) {
        thisDB.createObjectStore("tokens");
      }
    }

    openRequest.onsuccess = function(e) {

      resolve(e.target.result);

    }
    openRequest.onerror = function(e) {
      //Do something for the error
      console.error(e);
      reject(e);
    }

  });
}


function getToken(callback) {
  //console.log('calling getToken');
  openDB().then(function(db) {
    var transaction = db.transaction(["tokens"], "readonly");
    var objectStore = transaction.objectStore("tokens");

    var ob = objectStore.get(1);

    ob.onsuccess = function(e) {
      var result = e.target.result;
     // console.log('retrieved it',result);
      self.token = result.token;
     // console.log('callback', callback);
      if(callback) callback(result.token);
     // console.log('just set token');
    }
  });

}


function setToken(token) {

  openDB().then(function(db) {
    var transaction = db.transaction(["tokens"], "readwrite");
    var store = transaction.objectStore("tokens");

    //First - clear the store
    var req = store.clear();
    req.onsuccess = function (evt) {

      // store is empty. Populate it

      //Define a person
      var storedToken = {
        token: token
      }


      //Perform the add
      var request = store.add(storedToken, 1);

      request.onerror = function (e) {
        console.error("Error", e.target.error.name);
        //some type of error handler
      }
      request.onsuccess = function (e) {
      }
    };
    req.onerror = function (evt) {
      console.error("clearObjectStore:", evt.target.errorCode);
    };
  });
}


self.addEventListener('push', function(event) {
  event.waitUntil(

    getToken(function(){

    // Since this is no payload data with the first version
    // of Push notifications, here we'll grab some data from
    // an API and use it to populate a notification

    fetch('/alert-info/'+self.token)
        .then(function(response) {
          if (response.status !== 200) {
            // Throw an error so the promise is rejected and catch() is executed
            throw new Error('Invalid status code from alert details API: ' +
                response.status);
          }

          // Examine the text in the response
          return response.json();
        })
        .then(function(data) {

          // 	console.log(data)
          if (data.alerts.length === 0) {
            // Throw an error so the promise is rejected and catch() is executed
            throw new Error();
          }
          //Todo: what if there are multiple alerts?
          // hints at https://developers.google.com/web/updates/2015/05/notifying-you-of-changes-to-notifications?hl=en
          // see the ServiceWorkerRegistration.getNotifications() section

          var alert = data.alerts[0];
          var title = alert.title;
          var message = alert.message;
          var icon = '/icon-sun.png';

          // Add this to the data of the notification
          var urlToOpen = "/";

          var notificationData = {
            url: alert.link != null? alert.link : '/'
          };

          var notificationOptions = {
            body: message,
            icon: icon ,
            tag: alert.channel,
            data: notificationData
          };
          return self.registration.showNotification(title, notificationOptions);

        })
        .catch(function(err) {

          console.error('A Problem occured with handling the push msg', err);
          var title = 'An error occured';
          var message = 'We were unable to get the information for this ' +
              'push message';

          return self.registration.showNotification(title, {body:message});
        });
  })

  );
});

self.addEventListener('notificationclick', function(event) {
  var url = event.notification.data.url;
  event.notification.close();
  event.waitUntil(clients.openWindow(url));
});

self.token = 'unset';

self.addEventListener('message', function(event) {

  setToken(event.data.token);
  self.token = event.data.token;
});

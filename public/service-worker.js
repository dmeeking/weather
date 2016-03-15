'use strict';



function showNotification(title, body, icon, data) {
 // console.log('showNotification');
  var notificationOptions = {
    body: body,
    icon: icon ? icon : '/images/touch/chrome-touch-icon-192x192.png',
    tag: 'yowx-alert',
    data: data
  };
  return self.registration.showNotification(title, notificationOptions);
}

//token that ties user to alerts on the backend
self.token = ''

self.addEventListener('push', function(event) {
 // console.log('Received a push message', event);

  // Since this is no payload data with the first version
  // of Push notifications, here we'll grab some data from
  // an API and use it to populate a notification
  event.waitUntil(
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
        var icon = 'images/touch/chrome-touch-icon-192x192.png';

        // Add this to the data of the notification
        var urlToOpen = "/";

        var notificationFilter = {
          tag: alert.channel
        };

        var notificationData = {
          url: alert.link != null? alert.link : '/'
        };

        if (!self.registration.getNotifications) {
          return showNotification(title, message, icon, notificationData);
        }

        // Check if a notification is already displayed
        return self.registration.getNotifications(notificationFilter)
          .then(function(notifications) {
            if (notifications && notifications.length > 0) {
              // Start with one to account for the new notification
              // we are adding
              var notificationCount = 1;
              for (var i = 0; i < notifications.length; i++) {
                var existingNotification = notifications[i];
                if (existingNotification.data &&
                  existingNotification.data.notificationCount) {
                  notificationCount +=
                    existingNotification.data.notificationCount;
                } else {
                  notificationCount++;
                }
                existingNotification.close();
              }
              message = 'You have ' + notificationCount +
                'updates pending.';
              notificationData.notificationCount = notificationCount;
            }

            return showNotification(title, message, icon, notificationData);
          });
      })
      .catch(function(err) {
      
        console.error('A Problem occured with handling the push msg', err);
        var title = 'An error occured';
        var message = 'We were unable to get the information for this ' +
          'push message';

        return showNotification(title, message);
      })
  );

});

self.addEventListener('notificationclick', function(event) {
  var url = event.notification.data.url;
  event.notification.close();
  event.waitUntil(clients.openWindow(url));
});

self.addEventListener('message', function(event) {
 // console.log("message", event.data.token);
  self.token = event.data.token;
});

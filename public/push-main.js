
(function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){
'use strict';


var _pushClientEs = require('./push-client.es6.js');

var _pushClientEs2 = _interopRequireDefault(_pushClientEs);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

var API_KEY = 'AIzaSyBBh4ddPa96rQQNxqiq_qQj7sq1JdsNQUQ';

// Define a different server URL here if desire.
var PUSH_SERVER_URL = '';

function updateUIForPush(pushToggleSwitch) {
  // This div contains the UI for CURL commands to trigger a push
  var sendPushOptions = document.querySelector('.js-send-push-options');

  var stateChangeListener = function stateChangeListener(state, data) {
    // console.log(state);
    if (typeof state.interactive !== 'undefined') {
      if (state.interactive) {
        pushToggleSwitch.disabled = false;
      } else {
        pushToggleSwitch.disabled = true;
      }
    }

    if (typeof state.pushEnabled !== 'undefined') {
      if (state.pushEnabled) {
        pushToggleSwitch.checked = true;
      } else {
        pushToggleSwitch.checked = false;
      }
    }

    switch (state.id) {
      case 'ERROR':
        console.error(data);
        alert('Ooops a Problem Occurred', data);
        break;
      default:
        break;
    }
  };

  var subscriptionUpdate = function subscriptionUpdate(subscription) {
    //console.log('subscriptionUpdate: ', subscription);
  
    if (!subscription) {
      
      fetch(PUSH_SERVER_URL + '/unsubscribe/'+self.token+'/admin_all', {
        method: 'get',
        });

      return;
    }



    // We should figure the GCM curl command
    var produceGCMProprietaryCURLCommand = function produceGCMProprietaryCURLCommand() {
    var curlEndpoint = 'https://android.googleapis.com/gcm/send';
    var endpointSections = subscription.endpoint.split('/');
    var subscriptionId = endpointSections[endpointSections.length - 1];
      


    fetch(PUSH_SERVER_URL + '/subscribe/'+self.token+'/admin_all/'+subscriptionId, {
      method: 'get',
      }).then(function(response) {
      //console.log(response);
    });




      var curlCommand = 'curl --header "Authorization: key=' + API_KEY + '" --header Content-Type:"application/json" ' + curlEndpoint + ' -d "{\\"registration_ids\\":[\\"' + subscriptionId + '\\"], \\"data\\":{ \\"fred\\":\\"test\\"}  }"';
      return curlCommand;
    };

    var produceWebPushProtocolCURLCommand = function produceWebPushProtocolCURLCommand() {
      var curlEndpoint = subscription.endpoint;
      var curlCommand = 'curl --request POST ' + curlEndpoint;
      return curlCommand;
    };

    var curlCommand;
    if (subscription.endpoint.indexOf('https://android.googleapis.com/gcm/send') === 0) {
      curlCommand = produceGCMProprietaryCURLCommand();
    } else {
      curlCommand = produceWebPushProtocolCURLCommand();
    }


  };

  var pushClient = new _pushClientEs2.default(stateChangeListener, subscriptionUpdate);

  document.querySelector('#switch-alerts').addEventListener('click', function (event) {
    // Inverted because clicking will change the checked state by
    // the time we get here
    if (!event.target.checked) {
      pushClient.unsubscribeDevice();
    } else {
      pushClient.subscribeDevice();
    }
  });


  //ensure we have a unique userID in local storage
  var userToken = 0;
  self.token = userToken;
  if(typeof(Storage) !== "undefined") {
    userToken = localStorage.getItem("token");
    if(null == userToken)
    {
        userToken = (Math.random().toString(36)+'00000000000000000').slice(2, 10+2);
        localStorage.setItem("token", userToken);
    }
    self.token = userToken;
  } 

  // Check that service workers are supported
  if ('serviceWorker' in navigator) {
    navigator.serviceWorker.register('/service-worker.js', {
      scope: './'
    }).then(function(reg) {
    //  console.log('installing / posting', userToken);
      var messenger = reg.installing || navigator.serviceWorker.controller;
      messenger.postMessage({token: userToken});
    }).catch(function(err) {
      console.error('service worker error', err);
    });
  } else {
   // showErrorMessage('Service Worker Not Supported', 'Sorry this demo requires service worker support in your browser. ' + 'Please try this demo in Chrome or Firefox Nightly.');
  }


}

var toggleSwitch = document.querySelector('#switch-alerts');
toggleSwitch.initialised = false;

updateUIForPush(toggleSwitch);

},{"./push-client.es6.js":2}],2:[function(require,module,exports){
'use strict';

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var PushClient = function () {
  function PushClient(stateChangeCb, subscriptionUpdate) {
    var _this = this;

    _classCallCheck(this, PushClient);

    this._stateChangeCb = stateChangeCb;
    this._subscriptionUpdate = subscriptionUpdate;

    this.state = {
      UNSUPPORTED: {
        id: 'UNSUPPORTED',
        interactive: false,
        pushEnabled: false
      },
      INITIALISING: {
        id: 'INITIALISING',
        interactive: false,
        pushEnabled: false
      },
      PERMISSION_DENIED: {
        id: 'PERMISSION_DENIED',
        interactive: false,
        pushEnabled: false
      },
      PERMISSION_GRANTED: {
        id: 'PERMISSION_GRANTED',
        interactive: true
      },
      PERMISSION_PROMPT: {
        id: 'PERMISSION_PROMPT',
        interactive: true,
        pushEnabled: false
      },
      ERROR: {
        id: 'ERROR',
        interactive: false,
        pushEnabled: false
      },
      STARTING_SUBSCRIBE: {
        id: 'STARTING_SUBSCRIBE',
        interactive: false,
        pushEnabled: true
      },
      SUBSCRIBED: {
        id: 'SUBSCRIBED',
        interactive: true,
        pushEnabled: true
      },
      STARTING_UNSUBSCRIBE: {
        id: 'STARTING_UNSUBSCRIBE',
        interactive: false,
        pushEnabled: false
      },
      UNSUBSCRIBED: {
        id: 'UNSUBSCRIBED',
        interactive: true,
        pushEnabled: false
      }
    };

    if (!('serviceWorker' in navigator)) {
      this._stateChangeCb(this.state.UNSUPPORTED);
      return;
    }

    if (!('PushManager' in window)) {
      this._stateChangeCb(this.state.UNSUPPORTED);
      return;
    }

    if (!('permissions' in navigator)) {
      this._stateChangeCb(this.state.UNSUPPORTED);
      return;
    }

    if (!('showNotification' in ServiceWorkerRegistration.prototype)) {
      this._stateChangeCb(this.state.UNSUPPORTED);
      return;
    }

    navigator.serviceWorker.ready.then(function () {
      _this._stateChangeCb(_this.state.INITIALISING);
      _this.setUpPushPermission();
    });
  }

  _createClass(PushClient, [{
    key: '_permissionStateChange',
    value: function _permissionStateChange(permissionState) {
      // console.log('PushClient.permissionStateChange(): ', permissionState);
      // If the notification permission is denied, it's a permanent block
      switch (permissionState.state) {
        case 'denied':
          this._stateChangeCb(this.state.PERMISSION_DENIED);
          break;
        case 'granted':
          this._stateChangeCb(this.state.PERMISSION_GRANTED);
          break;
        case 'prompt':
          this._stateChangeCb(this.state.PERMISSION_PROMPT);
          break;
        default:
          break;
      }
    }
  }, {
    key: 'setUpPushPermission',
    value: function setUpPushPermission() {
      var _this2 = this;

      // console.log('PushClient.setUpPushPermission()');
      navigator.permissions.query({ name: 'push', userVisibleOnly: true }).then(function (permissionState) {
        // Set the initial state
        _this2._permissionStateChange(permissionState);

        // Handle Permission State Changes
        permissionState.onchange = function () {
          _this2._permissionStateChange(_this2);
        };

        // Check what the current push state is
        return navigator.serviceWorker.ready;
      }).then(function (serviceWorkerRegistration) {
        // Let's see if we have a subscription already
        return serviceWorkerRegistration.pushManager.getSubscription();
      }).then(function (subscription) {
        if (!subscription) {
          // NOOP since we have no subscription and the permission state
          // will inform whether to enable or disable the push UI
          return;
        }

        _this2._stateChangeCb(_this2.state.SUBSCRIBED);

        // Update the current state with the
        // subscriptionid and endpoint
        _this2._subscriptionUpdate(subscription);
      }).catch(function (err) {
        console.log('PushClient.setUpPushPermission() Error', err);
        _this2._stateChangeCb(_this2.state.ERROR, err);
      });
    }
  }, {
    key: 'subscribeDevice',
    value: function subscribeDevice() {
      var _this3 = this;

   //   console.log('PushClient.subscribeDevice()');

      this._stateChangeCb(this.state.STARTING_SUBSCRIBE);

      // We need the service worker registration to access the push manager
      navigator.serviceWorker.ready.then(function (serviceWorkerRegistration) {
        return serviceWorkerRegistration.pushManager.subscribe({ userVisibleOnly: true });
      }).then(function (subscription) {
        _this3._stateChangeCb(_this3.state.SUBSCRIBED);
        _this3._subscriptionUpdate(subscription);
      }).catch(function (subscriptionErr) {
        console.log('PushClient.subscribeDevice() Error', subscriptionErr);

        // Check for a permission prompt issue
        return navigator.permissions.query({ name: 'push', userVisibleOnly: true }).then(function (permissionState) {
          _this3._permissionStateChange(permissionState);

          // window.PushDemo.ui.setPushChecked(false);
          if (permissionState.state !== 'denied' && permissionState.state !== 'prompt') {
            // If the permission wasnt denied or prompt, that means the
            // permission was accepted, so this must be an error
            _this3._stateChangeCb(_this3.state.ERROR, subscriptionErr);
          }
        });
      });
    }
  }, {
    key: 'unsubscribeDevice',
    value: function unsubscribeDevice() {
      var _this4 = this;

    //  console.log('PushClient.unsubscribeDevice()');
      // Disable the switch so it can't be changed while
      // we process permissions
      // window.PushDemo.ui.setPushSwitchDisabled(true);

      this._stateChangeCb(this.state.STARTING_UNSUBSCRIBE);

      navigator.serviceWorker.ready.then(function (serviceWorkerRegistration) {
        return serviceWorkerRegistration.pushManager.getSubscription();
      }).then(function (pushSubscription) {
        // Check we have everything we need to unsubscribe
        if (!pushSubscription) {
          _this4._stateChangeCb(_this4.state.UNSUBSCRIBED);
          _this4._subscriptionUpdate(null);
          return;
        }

        // TODO: Remove the device details from the server
        // i.e. the pushSubscription.subscriptionId and
        // pushSubscription.endpoint
        return pushSubscription.unsubscribe().then(function (successful) {
          if (!successful) {
            // The unsubscribe was unsuccessful, but we can
            // remove the subscriptionId from our server
            // and notifications will stop
            // This just may be in a bad state when the user returns
            console.error('We were unable to unregister from push');
          }
        }).catch(function (e) {});
      }).then(function () {
        _this4._stateChangeCb(_this4.state.UNSUBSCRIBED);
        _this4._subscriptionUpdate(null);
      }).catch(function (e) {
        console.error('Error thrown while revoking push notifications. ' + 'Most likely because push was never registered', e);
      });
    }
  }]);

  return PushClient;
}();

exports.default = PushClient;

},{}]},{},[1]);
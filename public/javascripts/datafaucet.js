"use strict";

if(window.DataTower == undefined) {


window.DataTower = function() {

  this.streams = [];

  this.listStreams = function () {
    return this.streams;
  };

  this.addStream = function (streamName) {
    var streamExists = false;
    this.streams.forEach(function (stream) {
      if (stream.name == streamName) {
        streamExists = true;
      }
    });
    if (streamExists) {
      throw "Stream '" + streamName + "' already exists";
    } else {
      this.streams.push({
        name: streamName,
        faucets: []
      });
    }
  };

  this.delStream = function (streamName) {
    this.streams.forEach(function (stream, streamPos) {
      if (stream.name == streamName) {
        this.streams.splice(streamPos - 1, 1);
      }
    });
  };

  this.bind = function (streamName, faucet) {
    var args = Array.prototype.slice.call(arguments);
    var streamExists = false;
    this.streams.forEach(function (stream) {
      if (stream.name == streamName) {
        streamExists = true;
        stream.faucets.push(faucet);
      }
    });
    if (!streamExists) {
      this.addStream(streamName);
      this.bind.apply(this, args);
    }
  };

  this.unbind = function (streamName, faucet) {
    this.streams.forEach(function (stream, streamPos) {
      if (stream.name == stream) {
        stream.faucets.forEach(function (currentFaucet, faucetPos) {
          if (currentFaucet == faucet) {
            stream.faucets.splice(faucetPos - 1, 1);
          }
        });
      }
    });
  };

  this.sendTo = function (streamName) {
    var args = Array.prototype.slice.call(arguments);
    var streamExists = false;
    this.streams.forEach(function (stream) {
      if (stream.name == streamName) {
        streamExists = true;
        args.shift();
        stream.faucets.forEach(function (faucet) {
          faucet.apply(this, args);
        });
      }
    });
    if (!streamExists) {
      this.addStream(streamName);
      this.sendTo.apply(this, args);
    }
  };
};

}

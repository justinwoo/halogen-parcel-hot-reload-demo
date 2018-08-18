exports.unsafeInitialStateHandler = function(key) {
  return function(f) {
    return function(input) {
      if (
        module.hot &&
        window.unsafeStateBank &&
        window.unsafeStateBank.hasOwnProperty(key)
      ) {
        console.log("loading unsafe state bank value");
        return window.unsafeStateBank[key];
      } else {
        return f(input);
      }
    };
  };
};
exports.unsafeRenderStateHandler = function(key) {
  return function(f) {
    return function(state) {
      if (module.hot) {
        if (!window.unsafeStateBank) {
          window.unsafeStateBank = {};
        }
        console.log("storing unsafe state bank value", state);
        window.unsafeStateBank[key] = state;
      }
      return f(state);
    };
  };
};

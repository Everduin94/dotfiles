module.exports = activator => {
    return function(collection, name) {
        return config =>
            typeof name !== 'undefined' && name !== null
                ? activator(collection(name, config || {}))
                : activator(collection(config || {}));
    };
};

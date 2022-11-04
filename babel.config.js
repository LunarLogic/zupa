module.exports = {
  presets: [["@babel/preset-env", { targets: { node: "current" } }], "@babel/preset-typescript"],
  plugins: ["syntax-dynamic-import"],
  env: {
    test: {
      plugins: ["dynamic-import-node"],
    },
  },
};

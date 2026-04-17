module.exports = {
  testEnvironment: "jsdom",
  verbose: true,
  roots: ["<rootDir>/app/javascript"],
  transform: {
    "^.+\\.(ts|tsx|js)?$": ["ts-jest"],
  },
  testMatch: ["**/*.(test|spec).(ts|tsx|js)"],
  moduleNameMapper: {
    "\\.(css|less|sass|scss)$": "./app/javascript/__mocks__/styleMock.js",
    "\\.(jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2)$":
      "./app/javascript/__mocks__/fileMock.js",
  },
  setupFilesAfterEnv: ["./app/javascript/setupTests.tsx"],
  moduleDirectories: ["node_modules"],
  modulePaths: ["<rootDir>"],
};

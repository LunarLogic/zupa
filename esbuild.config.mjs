import { build } from "esbuild";
import path from "path";
import process from "process";

try {
  const dotenv = await import("dotenv");
  dotenv.config({ path: `.env.${process.env.NODE_ENV || "development"}` });
} catch {
  // dotenv is a devDependency - not available in production Docker builds
  // where env vars are set directly via Dockerfile ENV/ARG directives
}

const nodeEnv = process.env.NODE_ENV ? JSON.stringify(process.env.NODE_ENV) : '"development"';
const isProduction = nodeEnv === '"production"';

let define = {};
for (const k in process.env) {
  if (k.startsWith("REACT_")) {
    define[`process.env.${k}`] = JSON.stringify(process.env[k]);
  }
}

define = {
  ...define,
  "process.env.NODE_ENV": nodeEnv,
};

const bundleConfig = {
  entryPoints: ["application.tsx"],
  bundle: true,
  sourcemap: "linked",
  outdir: path.join(process.cwd(), "app/assets/builds"),
  absWorkingDir: path.join(process.cwd(), "app/javascript"),
  minify: isProduction,
  loader: {
    ".png": "dataurl",
    ".svg": "dataurl",
  },
  watch: !isProduction,
  define,
};

const adminBundleConfig = {
  entryPoints: ["admin.js"],
  bundle: true,
  sourcemap: "linked",
  outdir: path.join(process.cwd(), "app/assets/builds"),
  absWorkingDir: path.join(process.cwd(), "app/javascript/admin"),
  minify: isProduction,
  loader: {
    ".png": "dataurl",
    ".svg": "dataurl",
  },
  watch: !isProduction,
  define,
};

build(bundleConfig)
  .then(() => {
    console.log("Build completed successfully");
  })
  .catch((error) => {
    console.error(`Build failed with error: ${error.message}`);
    process.exit(1);
  });

build(adminBundleConfig)
  .then(() => {
    console.log("Build completed successfully");
  })
  .catch((error) => {
    console.error(`Build failed with error: ${error.message}`);
    process.exit(1);
  });

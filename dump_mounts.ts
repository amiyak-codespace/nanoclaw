import { RegisteredGroup } from './src/types.js';
import * as RUNNER from './src/container-runner.js';
import * as CONFIG from './src/config.js';

console.log("PROJECT_ROOT", CONFIG.PROJECT_ROOT);
console.log("HOST_PROJECT_ROOT", CONFIG.HOST_PROJECT_ROOT);
console.log("HOST_DATA_DIR", CONFIG.HOST_DATA_DIR);
console.log("HOST_STORE_DIR", CONFIG.HOST_STORE_DIR);

const grp = { folder: "main", name: "Me", defaultPersona: "" } as unknown as RegisteredGroup;

try {
  // We mock out spawn and child_process for testing
  const mounts = (RUNNER as any).buildVolumeMounts(grp, true);
  console.log("BUILT MOUNTS MAIN:", JSON.stringify(mounts, null, 2));
} catch (err) {
  console.error(err);
}

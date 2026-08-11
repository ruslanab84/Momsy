const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");
const { cleanupDeletedBaby } = require("../baby-deletion-cleanup");

const cliArgs = process.argv.slice(2);
const apply = cliArgs.length === 1 && cliArgs[0] === "--apply";

if (cliArgs.length > 0 && !apply) {
    throw new Error("Usage: node scripts/cleanup-orphaned-babies.js [--apply]");
}

initializeApp({ projectId: "momsy-cf74a" });

async function main() {
    const db = getFirestore();
    let count = 0;
    // ponytail: one-time full scan; add a paged task only if the family roster grows beyond a practical maintenance run.
    for (const familyRef of await db.collection("families").listDocuments()) {
        for (const babyRef of await familyRef.collection("babies").listDocuments()) {
            if ((await babyRef.get()).exists) {
                continue;
            }
            count += 1;
            console.log(`${apply ? "Cleaning" : "Would clean"} ${babyRef.path}`);
            if (apply) {
                await cleanupDeletedBaby(db, familyRef.id, babyRef.id);
            }
        }
    }
    console.log(`${apply ? "Cleaned" : "Found"} ${count} orphaned baby tree(s).`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

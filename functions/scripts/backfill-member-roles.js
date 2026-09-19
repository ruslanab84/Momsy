const { initializeApp } = require("firebase-admin/app");
const { getFirestore } = require("firebase-admin/firestore");

const cliArgs = process.argv.slice(2);
const apply = cliArgs.length === 1 && cliArgs[0] === "--apply";

if (cliArgs.length > 0 && !apply) {
    throw new Error("Usage: node scripts/backfill-member-roles.js [--apply]");
}

initializeApp({ projectId: "momsy-cf74a" });

// Pre-role memberships had full access: the creator becomes Mom, everyone else Dad.
// Rules no longer let clients self-repair a missing role, so run this before deploying them.
async function main() {
    const db = getFirestore();
    let count = 0;
    // ponytail: one-time full scan; add a paged task only if the family roster grows beyond a practical maintenance run.
    for (const familyRef of await db.collection("families").listDocuments()) {
        const createdBy = (await familyRef.get()).get("createdBy");
        for (const member of (await familyRef.collection("members").get()).docs) {
            if (member.get("roleRaw") !== undefined) {
                continue;
            }
            const uid = member.get("uid") ?? member.id;
            const roleRaw = uid === createdBy ? "Мама" : "Папа";
            count += 1;
            console.log(`${apply ? "Setting" : "Would set"} ${member.ref.path} roleRaw=${roleRaw}`);
            if (apply) {
                await member.ref.update({ roleRaw });
            }
        }
    }
    console.log(`${apply ? "Backfilled" : "Found"} ${count} member(s) without roleRaw.`);
}

main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});

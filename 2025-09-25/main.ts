import { DatabaseSync } from "node:sqlite";

const db = new DatabaseSync("klasse.db");
const stmt = db.prepare("SELECT * FROM students");
const rows = stmt.all();
console.log(rows);
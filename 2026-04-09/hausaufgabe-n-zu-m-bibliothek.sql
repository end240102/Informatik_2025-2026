-- ============================================================================
-- HAUSAUFGABE: N-zu-M-Beziehungen mit Zwischentabellen
-- Thema: Bibliotheksverwaltung mit Ausleihen
-- Geschätzter Bearbeitungsaufwand: ca. 50 Minuten
-- ============================================================================
--
-- AUFGABENSTELLUNG:
-- -----------------
-- Du sollst ein Datenbankmodell für eine Bibliothek erstellen.
-- Die Bibliothek verwaltet Bücher und Leser.
-- Ein Leser kann mehrere Bücher ausleihen.
-- Ein Buch kann von mehreren Lesern ausgeliehen werden (nacheinander).
-- Zusätzlich soll festgehalten werden, wie viele Tage ein Buch ausgeliehen wurde.
--
-- ERSTELLE FOLGENDE TABELLEN:
--   1. Tabelle "leser" für die Bibliotheksbenutzer
--   2. Tabelle "buch" für die Bücher
--   3. Tabelle "ausleihe" als Zwischentabelle mit N-zu-M-Beziehung
--
-- ============================================================================

-- HINWEIS: Lösche existierende Tabellen am Anfang (falls vorhanden)
DROP TABLE IF EXISTS ausleihe;
DROP TABLE IF EXISTS buch;
DROP TABLE IF EXISTS leser;

-- ============================================================================
-- AUFGABE 1: LESER-TABELLE (5 Punkte, ca. 5 Min.)
-- ============================================================================
-- Erstelle die Tabelle "leser" mit folgenden Anforderungen:
--   - id: INTEGER, PRIMARY KEY, AUTOINCREMENT
--   - name: TEXT, NOT NULL
--   - email: TEXT, NOT NULL, UNIQUE (jede Email darf nur einmal vorkommen)
--   - mitglied_seit: DATE (TEXT in SQLite), NOT NULL
--
-- DEIN CODE HIER:
CREATE TABLE leser(
    id INTEGER AUTOINCREMENT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    mitglied_seit TEXT NOT NULL
);

-- ============================================================================
-- AUFGABE 2: BUCH-TABELLE (5 Punkte, ca. 5 Min.)
-- ============================================================================
-- Erstelle die Tabelle "buch" mit folgenden Anforderungen:
--   - id: INTEGER, PRIMARY KEY, AUTOINCREMENT
--   - titel: TEXT, NOT NULL
--   - autor: TEXT, NOT NULL
--   - isbn: TEXT, UNIQUE (ISBN soll eindeutig sein, kann aber NULL sein falls unbekannt)
--   - erscheinungsjahr: INTEGER
--
-- DEIN CODE HIER:
CREATE TABLE buch(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    titel TEXT NOT NULL,
    autor TEXT NOT NULL,
    isbn TEXT UNIQUE,
    erscheinungsjahr INTEGER
)

-- ============================================================================
-- AUFGABE 3: AUSLEIHE-ZWISCHENTABELLE (20 Punkte, ca. 20 Min.)
-- ============================================================================
-- Erstelle die Tabelle "ausleihe" als Zwischentabelle für die N-zu-M-Beziehung.
--
-- ANFORDERUNGEN:
--   Spalten:
--   - leser_id: INTEGER, NOT NULL
--   - buch_id: INTEGER, NOT NULL
--   - ausleih_datum: DATE (TEXT), NOT NULL
--   - rueckgabe_datum: DATE (TEXT), kann NULL sein (noch nicht zurückgegeben)
--   - anzahl_tage: INTEGER, NOT NULL
--
--   Constraints:
--   - PRIMARY KEY: Zusammengesetzt aus (leser_id, buch_id, ausleih_datum)
--     ERKLÄRUNG: Derselbe Leser kann dasselbe Buch mehrfach ausleihen, 
--     aber zu unterschiedlichen Zeitpunkten!
--   
--   - FOREIGN KEY leser_id → leser(id):
--     * ON DELETE RESTRICT (Verhindere Löschen, wenn noch Ausleihen existieren)
--     * ON UPDATE CASCADE
--   
--   - FOREIGN KEY buch_id → buch(id):
--     * ON DELETE RESTRICT (Verhindere Löschen, wenn noch Ausleihen existieren)
--     * ON UPDATE CASCADE
--   
--   - CHECK: anzahl_tage muss größer als 0 sein
--
-- DEIN CODE HIER:
CREATE TABLE ausleihe(
    leser_id INTEGER NOT NULL,
    buch_id INTEGER NOT NULL,
    ausleih_datum TEXT NOT NULL,
    rueckgabe_datum TEXT,
    anzahl_tage INTEGER NOT NULL,
    
    PRIMARY KEY (leser_id, buch_id, ausleih_datum),
    
    CONSTRAINT fk_leser
        FOREIGN KEY (leser_id)
        REFERENCES leser(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT fk_buch
        FOREIGN KEY (buch_id)
        REFERENCES buch(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_anzahl_tage
        CHECK (anzahl_tage > 0)
);

-- ============================================================================
-- AUFGABE 4: INDEXE ERSTELLEN (5 Punkte, ca. 5 Min.)
-- ============================================================================
-- Erstelle sinnvolle Indexe für folgende Anwendungsfälle:
--
--   a) Schnelle Suche nach Leser-Namen
--   b) Schnelle Suche nach Buch-Titeln
--   c) Schnelle Abfrage: Welche Bücher sind aktuell ausgeliehen?
--      (rueckgabe_datum IS NULL)
--
-- ERKLÄRUNG: Begründe in einem Kommentar, warum jeder Index sinnvoll ist!
--
-- DEIN CODE HIER:
CREATE INDEX idx_leser_name ON leser(name);

CREATE INDEX idx_buch_title ON buch(title);

CREATE INDEX idx_ausleihe_rueckgabe_null ON ausleihe(rueckgabe_datum);

-- ============================================================================
-- AUFGABE 5: BEISPIELDATEN EINFÜGEN (5 Punkte, ca. 5 Min.)
-- ============================================================================
-- Füge folgende Testdaten ein:
--
-- LESER:
--   1, 'Max Mustermann', 'max@email.de', '2023-01-15'
--   2, 'Maria Musterfrau', 'maria@email.de', '2023-03-20'
--   3, 'Peter Schmidt', 'peter@email.de', '2024-01-10'
--
-- BÜCHER:
--   1, 'Der Herr der Ringe', 'J.R.R. Tolkien', '978-3608939791', 1954
--   2, 'Harry Potter 1', 'J.K. Rowling', '978-3551551679', 1997
--   3, 'Die Verwandlung', 'Franz Kafka', '978-3150099007', 1915
--   4, '1984', 'George Orwell', '978-3548234106', 1949
--
-- AUSLEIHEN:
--   Max hat "Der Herr der Ringe" am '2024-01-10' für 14 Tage ausgeliehen,
--   zurückgegeben am '2024-01-24'
--
--   Max hat "Harry Potter 1" am '2024-02-01' für 10 Tage ausgeliehen,
--   noch nicht zurückgegeben (rueckgabe_datum = NULL)
--
--   Maria hat "1984" am '2024-01-15' für 7 Tage ausgeliehen,
--   zurückgegeben am '2024-01-22'
--
--   Maria hat "Der Herr der Ringe" am '2024-02-05' für 21 Tage ausgeliehen,
--   noch nicht zurückgegeben
--
--   Peter hat "Die Verwandlung" am '2024-01-20' für 5 Tage ausgeliehen,
--   zurückgegeben am '2024-01-25'
--
-- DEIN CODE HIER:
-- Leser einfügen
INSERT INTO leser (id, name, email, registriert_am) VALUES
    (1, 'Max Mustermann', 'max@email.de', '2023-01-15'),
    (2, 'Maria Musterfrau', 'maria@email.de', '2023-03-20'),
    (3, 'Peter Schmidt', 'peter@email.de', '2024-01-10');

-- Bücher einfügen
INSERT INTO buch (id, title, autor, isbn, erscheinungsjahr) VALUES
    (1, 'Der Herr der Ringe', 'J.R.R. Tolkien', '978-3608939791', 1954),
    (2, 'Harry Potter 1', 'J.K. Rowling', '978-3551551679', 1997),
    (3, 'Die Verwandlung', 'Franz Kafka', '978-3150099007', 1915),
    (4, '1984', 'George Orwell', '978-3548234106', 1949);

-- Ausleihen einfügen
INSERT INTO ausleihe (leser_id, buch_id, ausleih_datum, rueckgabe_datum, anzahl_tage) VALUES
    (1, 1, '2024-01-10', '2024-01-24', 14),
    
    (1, 2, '2024-02-01', NULL, 10),
    
    (2, 4, '2024-01-15', '2024-01-22', 7),
    
    (2, 1, '2024-02-05', NULL, 21),
    
    (3, 3, '2024-01-20', '2024-01-25', 5);


-- ============================================================================
-- AUFGABE 6: ABFRAGEN SCHREIBEN (10 Punkte, ca. 10 Min.)
-- ============================================================================
-- Schreibe SQL-Abfragen für folgende Fragestellungen:
--
-- a) Zeige alle Ausleihen mit Lesernamen, Buchtitel und Ausleihzeitraum
--    Sortiert nach Ausleihdatum (neueste zuerst)
--
-- b) Welche Bücher sind aktuell ausgeliehen? 
--    (Titel, Lesername, seit wann ausgeliehen)
--
-- c) Wie oft wurde jedes Buch insgesamt ausgeliehen?
--    (Titel + Anzahl der Ausleihen)
--
-- d) Welcher Leser hat die meisten Bücher insgesamt ausgeliehen?
--    (Hinweis: zähle alle Ausleihen pro Leser)
--
-- DEIN CODE HIER:
a)
SELECT 
    l.name AS leser_name,
    b.title AS buch_title,
    a.ausleih_datum,
    a.rueckgabe_datum,
    a.anzahl_tage
FROM ausleihe a
JOIN leser l ON a.leser_id = l.id
JOIN buch b ON a.buch_id = b.id
ORDER BY a.ausleih_datum DESC;

b)
SELECT 
    b.title AS buch_title,
    l.name AS leser_name,
    a.ausleih_datum AS seit_wann_ausgeliehen
FROM ausleihe a
JOIN leser l ON a.leser_id = l.id
JOIN buch b ON a.buch_id = b.id
WHERE a.rueckgabe_datum IS NULL;

c)
SELECT 
    b.title AS buch_title,
    COUNT(*) AS anzahl_ausleihen
FROM buch b
LEFT JOIN ausleihe a ON b.id = a.buch_id
GROUP BY b.id, b.title
ORDER BY anzahl_ausleihen DESC;

d)
SELECT 
    l.name AS leser_name,
    COUNT(*) AS anzahl_ausleihen
FROM leser l
JOIN ausleihe a ON l.id = a.leser_id
GROUP BY l.id, l.name
ORDER BY anzahl_ausleihen DESC
LIMIT 1;


-- ============================================================================
-- BONUSAUFGABE (Optional, +5 Punkte)
-- ============================================================================
-- Erstelle eine VIEW (Sicht) namens "aktuelle_ausleihen", die alle 
-- aktuell ausgeliehenen Bücher mit Lesernamen, Buchtitel und Ausleihdatum zeigt.
--
-- DEIN CODE HIER:
CREATE VIEW aktuelle_ausleihen AS
SELECT 
    l.name AS leser_name,
    b.title AS buch_title,
    a.ausleih_datum
FROM ausleihe a
JOIN leser l ON a.leser_id = l.id
JOIN buch b ON a.buch_id = b.id
WHERE a.rueckgabe_datum IS NULL;


-- ============================================================================
-- BEWERTUNGSKRITERIEN:
-- ============================================================================
--
-- Aufgabe 1 (Leser-Tabelle):        5 Punkte
--   - Korrekte Spalten               2 Punkte
--   - Korrekte Constraints           3 Punkte
--
-- Aufgabe 2 (Buch-Tabelle):         5 Punkte
--   - Korrekte Spalten               2 Punkte
--   - Korrekte Constraints           3 Punkte
--
-- Aufgabe 3 (Ausleihe-Tabelle):    20 Punkte
--   - Korrekte Spalten               4 Punkte
--   - Composite PRIMARY KEY korrekt  4 Punkte
--   - Foreign Keys korrekt           6 Punkte (je 3 Punkte)
--   - ON DELETE/UPDATE korrekt       4 Punkte
--   - CHECK Constraint korrekt       2 Punkte
--
-- Aufgabe 4 (Indexe):               5 Punkte
--   - Korrekte Indexe                3 Punkte
--   - Begründungen                   2 Punkte
--
-- Aufgabe 5 (Beispieldaten):        5 Punkte
--
-- Aufgabe 6 (Abfragen):            10 Punkte
--   - Abfrage a korrekt              3 Punkte
--   - Abfrage b korrekt              3 Punkte
--   - Abfrage c korrekt              2 Punkte
--   - Abfrage d korrekt              2 Punkte
--
-- Bonus (VIEW):                     5 Punkte
--
-- GESAMT: 50 (+5 Bonus) Punkte
--
-- ============================================================================
-- HINWEISE ZUR BEARBEITUNG:
-- ============================================================================
--
-- 1. Speichere deine Lösung in einer Datei namens "bibliothek_loesung.sql"
-- 2. Teste deine SQL-Befehle in SQLite:
--    sqlite3 bibliothek.db < bibliothek_loesung.sql
-- 3. Achte auf die Reihenfolge: Erst Tabellen, dann Indexe, dann Daten, dann Abfragen
-- 4. Bei Fehlern: Überprüfe die Syntax deiner CONSTRAINTS
-- 5. Die Kommentare (mit --) sind nur zur Erklärung, du kannst sie löschen
--
-- ============================================================================
-- LÖSUNGSHINWEISE (für Lehrkraft):
-- ============================================================================
--
-- Die Lösung befindet sich in der Datei "bibliothek_musterloesung.sql"
--
-- Wichtige Kontrollpunkte:
-- - Composite PK in Ausleihe muss alle 3 Spalten enthalten (leser_id, buch_id, ausleih_datum)
-- - ON DELETE RESTRICT verhindert das Löschen von Lesern/Büchern mit offenen Ausleihen
-- - Der Index auf rueckgabe_datum ermöglicht effiziente Abfragen für "aktuell ausgeliehen"
--

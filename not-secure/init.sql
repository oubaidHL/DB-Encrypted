CREATE TABLE IF NOT EXISTS clients (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    nom TEXT NOT NULL,
    date_naissance DATE NOT NULL,
    email TEXT NOT NULL,
    carte_bancaire TEXT NOT NULL
);

INSERT INTO clients (nom, date_naissance, email, carte_bancaire)
VALUES ('Oubaid', '1998-03-12', 'oubaid@email.com', '4532-1111-2222-3333');
INSERT INTO clients (nom, date_naissance, email, carte_bancaire)
VALUES ('Farah', '1999-07-21', 'farah@email.com', '5123-4444-5555-6666');
INSERT INTO clients (nom, date_naissance, email, carte_bancaire)
VALUES ('Sebastien', '1995-11-05', 'sebastien@email.com', '4012-7777-8888-9999');
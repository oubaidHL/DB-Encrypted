import sqlite3
import os
from cryptography.hazmat.primitives import hashes, serialization
from cryptography.hazmat.primitives.asymmetric import rsa, padding
from cryptography.hazmat.backends import default_backend

DB_PATH = '/root/db/clients.db'
KEY_PATH = '/root/db/private_key.pem'
PUB_PATH = '/root/db/public_key.pem'

# 1. Generate RSA Keys if they don't exist
if not os.path.exists(KEY_PATH):
    # FIXED: Using rsa.generate_private_key instead of serialization
    private_key = rsa.generate_private_key(
        public_exponent=65537,
        key_size=2048,
        backend=default_backend()
    )
    
    with open(KEY_PATH, "wb") as f:
        f.write(private_key.private_bytes(
            encoding=serialization.Encoding.PEM,
            format=serialization.PrivateFormat.PKCS8,
            encryption_algorithm=serialization.NoEncryption()
        ))
    
    public_key = private_key.public_key()
    with open(PUB_PATH, "wb") as f:
        f.write(public_key.public_bytes(
            encoding=serialization.Encoding.PEM, 
            format=serialization.PublicFormat.SubjectPublicKeyInfo
        ))
    print("Keys generated successfully.")

# 2. Setup DB
conn = sqlite3.connect(DB_PATH)
cursor = conn.cursor()
cursor.execute('DROP TABLE IF EXISTS secure_clients') # Clean start for testing
cursor.execute('''CREATE TABLE IF NOT EXISTS secure_clients 
                  (id INTEGER PRIMARY KEY, nom TEXT, encrypted_card BLOB)''')

def encrypt_data(data):
    with open(PUB_PATH, "rb") as f:
        pub_key = serialization.load_pem_public_key(f.read(), backend=default_backend())
    return pub_key.encrypt(
        data.encode(), 
        padding.OAEP(
            mgf=padding.MGF1(algorithm=hashes.SHA256()), 
            algorithm=hashes.SHA256(), 
            label=None
        )
    )

# 3. Insert Encrypted Data
data_to_insert = [('Oubaid', '4532-1111-2222-3333'), ('Farah', '5123-4444-5555-6666')]
for name, card in data_to_insert:
    encrypted = encrypt_data(card)
    cursor.execute("INSERT INTO secure_clients (nom, encrypted_card) VALUES (?, ?)", (name, encrypted))

conn.commit()
conn.close()
print("Database encrypted and saved in /root/db/clients.db")
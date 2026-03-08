-- init.sql (for local testing)
CREATE TABLE IF NOT EXISTS greetings (
    id SERIAL PRIMARY KEY,
    message TEXT NOT NULL
);

INSERT INTO greetings (message) VALUES
    ('Hello from Kubernetes!'),
    ('Welcome to the EKS workshop!'),
    ('PostgreSQL is running in a pod!'),
    ('GitOps with ArgoCD is awesome!'),
    ('This greeting was seeded automatically!')
ON CONFLICT DO NOTHING;

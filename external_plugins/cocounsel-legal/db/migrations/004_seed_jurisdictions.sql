-- ---------------------------------------------------------------------------
-- Migration 004: Seed jurisdictions reference table
-- ---------------------------------------------------------------------------
-- Populates all 50 U.S. states, DC, territories, and federal circuits.
-- ---------------------------------------------------------------------------

BEGIN;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM schema_migrations WHERE version = 4) THEN
        RAISE NOTICE 'Migration 004 already applied — skipping';
        RETURN;
    END IF;

    -- States
    INSERT INTO jurisdictions (name, abbreviation, jurisdiction_type) VALUES
        ('Alabama', 'AL', 'state'),
        ('Alaska', 'AK', 'state'),
        ('Arizona', 'AZ', 'state'),
        ('Arkansas', 'AR', 'state'),
        ('California', 'CA', 'state'),
        ('Colorado', 'CO', 'state'),
        ('Connecticut', 'CT', 'state'),
        ('Delaware', 'DE', 'state'),
        ('Florida', 'FL', 'state'),
        ('Georgia', 'GA', 'state'),
        ('Hawaii', 'HI', 'state'),
        ('Idaho', 'ID', 'state'),
        ('Illinois', 'IL', 'state'),
        ('Indiana', 'IN', 'state'),
        ('Iowa', 'IA', 'state'),
        ('Kansas', 'KS', 'state'),
        ('Kentucky', 'KY', 'state'),
        ('Louisiana', 'LA', 'state'),
        ('Maine', 'ME', 'state'),
        ('Maryland', 'MD', 'state'),
        ('Massachusetts', 'MA', 'state'),
        ('Michigan', 'MI', 'state'),
        ('Minnesota', 'MN', 'state'),
        ('Mississippi', 'MS', 'state'),
        ('Missouri', 'MO', 'state'),
        ('Montana', 'MT', 'state'),
        ('Nebraska', 'NE', 'state'),
        ('Nevada', 'NV', 'state'),
        ('New Hampshire', 'NH', 'state'),
        ('New Jersey', 'NJ', 'state'),
        ('New Mexico', 'NM', 'state'),
        ('New York', 'NY', 'state'),
        ('North Carolina', 'NC', 'state'),
        ('North Dakota', 'ND', 'state'),
        ('Ohio', 'OH', 'state'),
        ('Oklahoma', 'OK', 'state'),
        ('Oregon', 'OR', 'state'),
        ('Pennsylvania', 'PA', 'state'),
        ('Rhode Island', 'RI', 'state'),
        ('South Carolina', 'SC', 'state'),
        ('South Dakota', 'SD', 'state'),
        ('Tennessee', 'TN', 'state'),
        ('Texas', 'TX', 'state'),
        ('Utah', 'UT', 'state'),
        ('Vermont', 'VT', 'state'),
        ('Virginia', 'VA', 'state'),
        ('Washington', 'WA', 'state'),
        ('West Virginia', 'WV', 'state'),
        ('Wisconsin', 'WI', 'state'),
        ('Wyoming', 'WY', 'state')
    ON CONFLICT (name) DO NOTHING;

    -- District of Columbia
    INSERT INTO jurisdictions (name, abbreviation, jurisdiction_type) VALUES
        ('District of Columbia', 'DC', 'territorial')
    ON CONFLICT (name) DO NOTHING;

    -- Territories
    INSERT INTO jurisdictions (name, abbreviation, jurisdiction_type) VALUES
        ('American Samoa', 'AS', 'territorial'),
        ('Guam', 'GU', 'territorial'),
        ('Northern Mariana Islands', 'MP', 'territorial'),
        ('Puerto Rico', 'PR', 'territorial'),
        ('U.S. Virgin Islands', 'VI', 'territorial')
    ON CONFLICT (name) DO NOTHING;

    -- Federal courts
    INSERT INTO jurisdictions (name, abbreviation, jurisdiction_type) VALUES
        ('Federal', 'US', 'federal'),
        ('1st Circuit', '1st Cir.', 'federal'),
        ('2nd Circuit', '2nd Cir.', 'federal'),
        ('3rd Circuit', '3rd Cir.', 'federal'),
        ('4th Circuit', '4th Cir.', 'federal'),
        ('5th Circuit', '5th Cir.', 'federal'),
        ('6th Circuit', '6th Cir.', 'federal'),
        ('7th Circuit', '7th Cir.', 'federal'),
        ('8th Circuit', '8th Cir.', 'federal'),
        ('9th Circuit', '9th Cir.', 'federal'),
        ('10th Circuit', '10th Cir.', 'federal'),
        ('11th Circuit', '11th Cir.', 'federal'),
        ('D.C. Circuit', 'D.C. Cir.', 'federal'),
        ('Federal Circuit', 'Fed. Cir.', 'federal'),
        ('Supreme Court', 'SCOTUS', 'federal')
    ON CONFLICT (name) DO NOTHING;

    INSERT INTO schema_migrations (version, name) VALUES (4, '004_seed_jurisdictions');
END;
$$;

COMMIT;

CREATE TABLE System (
                key TEXT NOT NULL PRIMARY KEY,
                value TEXT NOT NULL
            );
CREATE TABLE Ontology(
                id TEXT NOT NULL PRIMARY KEY,
                name TEXT NOT NULL,
                dataUrl TEXT NOT NULL,
                ontologyPrefix TEXT NOT NULL,
                UNIQUE (name)
            );
CREATE TABLE ReferenceSet (
                id TEXT NOT NULL PRIMARY KEY,
                name TEXT NOT NULL,
                description TEXT,
                assemblyId TEXT,
                isDerived INTEGER,
                md5checksum TEXT,
                ncbiTaxonId INTEGER,
                sourceAccessions TEXT,
                sourceUri TEXT,
                dataUrl TEXT NOT NULL,
                UNIQUE (name)
            );
CREATE TABLE Reference (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL,
                referenceSetId TEXT NOT NULL,
                length INTEGER,
                isDerived INTEGER,
                md5checksum TEXT,
                ncbiTaxonId INTEGER,
                sourceAccessions TEXT,
                sourceDivergence REAL,
                sourceUri TEXT,
                UNIQUE (referenceSetId, name),
                FOREIGN KEY(referenceSetId) REFERENCES ReferenceSet(id)
                    ON DELETE CASCADE
            );
CREATE TABLE Dataset (
                id TEXT NOT NULL PRIMARY KEY,
                name TEXT NOT NULL,
                description TEXT,
                info TEXT,
                UNIQUE (name)
            );
CREATE TABLE ReadGroupSet (
                id TEXT NOT NULL PRIMARY KEY,
                name TEXT NOT NULL,
                datasetId TEXT NOT NULL,
                referenceSetId TEXT NOT NULL,
                programs TEXT,
                stats TEXT NOT NULL,
                dataUrl TEXT NOT NULL,
                indexFile TEXT NOT NULL,
                UNIQUE (datasetId, name),
                FOREIGN KEY(datasetId) REFERENCES Dataset(id)
                    ON DELETE CASCADE,
                FOREIGN KEY(referenceSetId) REFERENCES ReferenceSet(id)
            );
CREATE TABLE ReadGroup (
                id TEXT NOT NULL PRIMARY KEY,
                readGroupSetId TEXT NOT NULL,
                name TEXT NOT NULL,
                predictedInsertSize INTEGER,
                sampleName TEXT,
                description TEXT,
                stats TEXT NOT NULL,
                experiment TEXT NOT NULL,
                biosampleId TEXT,
                created TEXT,
                updated TEXT,
                UNIQUE (readGroupSetId, name),
                FOREIGN KEY(readGroupSetId) REFERENCES ReadGroupSet(id)
                    ON DELETE CASCADE
            );
CREATE TABLE CallSet (
                id TEXT NOT NULL PRIMARY KEY,
                name TEXT NOT NULL,
                variantSetId TEXT NOT NULL,
                biosampleId TEXT,
                UNIQUE (variantSetId, name),
                FOREIGN KEY(variantSetId) REFERENCES VariantSet(id)
                    ON DELETE CASCADE
            );
CREATE TABLE VariantSet (
                id TEXT NOT NULL PRIMARY KEY,
                name TEXT NOT NULL,
                datasetId TEXT NOT NULL,
                referenceSetId TEXT NOT NULL,
                created TEXT,
                updated TEXT,
                metadata TEXT,
                dataUrlIndexMap TEXT NOT NULL,
                UNIQUE (datasetID, name),
                FOREIGN KEY(datasetId) REFERENCES Dataset(id)
                    ON DELETE CASCADE,
                FOREIGN KEY(referenceSetId) REFERENCES ReferenceSet(id)
            );
CREATE TABLE VariantAnnotationSet (
                id TEXT NOT NULL PRIMARY KEY,
                name TEXT NOT NULL,
                variantSetId TEXT NOT NULL,
                ontologyId TEXT NOT NULL,
                analysis TEXT,
                annotationType TEXT,
                created TEXT,
                updated TEXT,
                UNIQUE (variantSetId, name),
                FOREIGN KEY(variantSetId) REFERENCES VariantSet(id)
                    ON DELETE CASCADE,
                FOREIGN KEY(ontologyId) REFERENCES Ontology(id)
            );
CREATE TABLE FeatureSet (
                id TEXT NOT NULL PRIMARY KEY,
                name TEXT NOT NULL,
                datasetId TEXT NOT NULL,
                referenceSetId TEXT NOT NULL,
                ontologyId TEXT NOT NULL,
                info TEXT,
                sourceUri TEXT,
                dataUrl TEXT NOT NULL,
                UNIQUE (datasetId, name),
                FOREIGN KEY(datasetId) REFERENCES Dataset(id)
                    ON DELETE CASCADE,
                FOREIGN KEY(referenceSetId) REFERENCES ReferenceSet(id)
                FOREIGN KEY(ontologyId) REFERENCES Ontology(id)
            );
CREATE TABLE Biosample (
                id TEXT NOT NULL PRIMARY KEY,
                datasetId TEXT NOT NULL,
                name TEXT NOT NULL,
                description TEXT,
                disease TEXT,
                created TEXT,
                updated TEXT,
                individualId TEXT,
                info TEXT,
                UNIQUE (datasetId, name),
                FOREIGN KEY(datasetId) REFERENCES Dataset(id)
                    ON DELETE CASCADE
            );
CREATE TABLE Individual (
                id TEXT NOT NULL PRIMARY KEY,
                datasetId TEXT NOT NULL,
                name TEXT,
                description TEXT,
                created TEXT NOT NULL,
                updated TEXT,
                species TEXT,
                sex TEXT,
                info TEXT,
                UNIQUE (datasetId, name),
                FOREIGN KEY(datasetId) REFERENCES Dataset(id)
                    ON DELETE CASCADE
            );
CREATE TABLE PhenotypeAssociationSet (
                id TEXT NOT NULL PRIMARY KEY,
                name TEXT,
                datasetId TEXT NOT NULL,
                dataUrl TEXT NOT NULL,
                UNIQUE (datasetId, name),
                FOREIGN KEY(datasetId) REFERENCES Dataset(id)
                    ON DELETE CASCADE
            );
CREATE TABLE RnaQuantificationSet (
                id TEXT NOT NULL PRIMARY KEY,
                name TEXT NOT NULL,
                datasetId TEXT NOT NULL,
                referenceSetId TEXT NOT NULL,
                info TEXT,
                dataUrl TEXT NOT NULL,
                UNIQUE (datasetId, name),
                FOREIGN KEY(datasetId) REFERENCES Dataset(id)
                    ON DELETE CASCADE,
                FOREIGN KEY(referenceSetId) REFERENCES ReferenceSet(id)
            );

const fs = require('fs');
const Ajv = require('ajv');

const inFile = process.argv[2];
const inst = require(inFile);

const instSchema = JSON.parse(fs.readFileSync('./schemas/instance.json', 'utf8'));
const uuidSchema = JSON.parse(fs.readFileSync('./schemas/uuid.json', 'utf8'));
const tagsSchema = JSON.parse(fs.readFileSync('./schemas/tags.schema', 'utf8'));
const metadataSchema = JSON.parse(fs.readFileSync('./schemas/metadata.schema', 'utf8'));
const hrSchema = JSON.parse(fs.readFileSync('./schemas/holdingsrecord.json', 'utf8'));
const itemSchema = JSON.parse(fs.readFileSync('./schemas/item.json', 'utf8'));

const ajv = new Ajv({ schemaId: 'id', coerceTypes: true }); // options can be passed, e.g. {allErrors: true}
ajv.addMetaSchema(require('ajv/lib/refs/json-schema-draft-04.json'));
ajv.addSchema(uuidSchema, 'uuid.json');
ajv.addSchema(tagsSchema, 'raml-util/schemas/tags.schema');
ajv.addSchema(metadataSchema, 'raml-util/schemas/metadata.schema');
ajv.addSchema(hrSchema, 'holdingsrecord.json');
ajv.addSchema(itemSchema, 'item.json');
validate = ajv.compile(instSchema);

inst.instances.forEach(i => {
  let valid = validate(i);
  if (!valid) console.log(validate.errors);
});
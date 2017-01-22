from ga4gh.client import client
server = client.HttpClient("http://localhost:8000")

dataset = server.search_datasets().next()

print "Individuals:"
for individual in server.search_individuals(dataset_id=dataset.id):
    print "Individual: {}".format(individual.name)
    print " id: {}".format(individual.id)
    print " dataset_id: {}".format(individual.dataset_id)
    print " description: {}".format(individual.description)

print "RNA Quantification Sets:"
for rna_quant_set in server.search_rna_quantification_sets(dataset_id=dataset.id):
    print(" id: {}".format(rna_quant_set.id))
    print(" dataset_id: {}".format(rna_quant_set.dataset_id))
    print(" name: {}\n".format(rna_quant_set.name))

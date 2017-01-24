from ga4gh.client import client
c = client.HttpClient("http://ga4gh_server:8000")

dataset = c.search_datasets().next()

print "Individuals:"
for individual in c.search_individuals(dataset_id=dataset.id):
    print "Individual: {}".format(individual.name)
    print " id: {}".format(individual.id)
    print " dataset_id: {}".format(individual.dataset_id)
    print " description: {}".format(individual.description)

print "RNA Quantification Sets:"
for rna_quant_set in c.search_rna_quantification_sets(dataset_id=dataset.id):
    print(" id: {}".format(rna_quant_set.id))
    print(" dataset_id: {}".format(rna_quant_set.dataset_id))
    print(" name: {}\n".format(rna_quant_set.name))

print "RNA Quantifications:"
for rna_quant in c.search_rna_quantifications(rna_quantification_set_id=rna_quant_set.id):
    print("RNA Quantification: {}".format(rna_quant.name))
    print(" id: {}".format(rna_quant.id))
    print(" description: {}\n".format(rna_quant.description))

print "RNA Expression Levels:"
for expression in c.search_expression_levels(rna_quantification_id=rna_quant.id):
    print("Expression Level: {}".format(expression.name))
    print(" id: {}".format(expression.id))
    print(" feature: {}".format(expression.feature_id))
    print(" expression: {}".format(expression.expression))

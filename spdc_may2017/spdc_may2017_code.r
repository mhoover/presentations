# spdc network talk
# author: matt hoover (matthew.a.hoover at gmail.com)

# load packages
if('ggnet' %in% installed.packages()) {
    library(ggnet)
} else {
    require(devtools)
    install_github('mhoover/ggnet/ggnet')
}
require(statnet)

# load data
mat <- as.matrix(read.csv('matrix.csv', header = FALSE, sep = ','))
el <- read.csv('edgelist.csv', header = TRUE, sep = ',')
attr <- read.csv('attributes.csv', header = TRUE, sep = ',',
                 stringsAsFactors = FALSE)

# not necessary -- just don't want to forget this is a matrix object
colnames(mat) <- NULL

# create network object (for graphing with ggnet package)
net <- network(el)

# add attributes to network object
set.vertex.attribute(net, 'age', attr$age)
net %v% 'gender' <- attr$gender # an alternate way to add attributes

### summary statistics
# degree, or number of connections
sum(mat) # using a matrix
nrow(el) # using an edgelist
degree(net, gmode = 'graph', cmode = 'freeman') # using a network object

# however, if the network is directed, then direction matters
# indegree (inbound connections)
apply(mat, 2, function(x) {sum(x)}) # using a matrix
table(el$rec) # using an edgelist
degree(net, cmode = 'indegree') # using a network object

# outdegree (outbound connections)
apply(mat, 1, function(x) {sum(x)}) # using a matrix
table(el$snd) # using an edgelist
degree(net, cmode = 'outdegree') # using a network object





### visualizations
# capture coordinates for consistently node placement (from the `ggnet` package)
coords <- coord_place(net)

# plot some networks
# plain network
ggnet(net, direct = TRUE, title = 'Simple Network Graph', coords = coords)

# network with gender of individuals
ggnet(net, direct = TRUE, shape = 'gender', coords = coords, legend = TRUE,
      title = 'Network Graph with Gender')

# network with gender and age of individuals
ggnet(net, direct = TRUE, shape = 'gender', color = 'age', coords = coords,
      gradient = TRUE, legend = TRUE, title = 'Network Graph with Gender and Age')


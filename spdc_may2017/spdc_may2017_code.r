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


### community detection
# load matrix into an igraph object
# note, `statnet` tools and `igraph` don't play well together, so not loading
#  `igraph`
mati <- igraph::graph.adjacency(mat, mode = 'directed')

# girvan-newman community detection
gn_results <- igraph::edge.betweenness.community(mati)
gn_results$membership

pdf('gn_dendrogram.pdf')
    plot(as.dendrogram(gn_results))
dev.off()


### visualizations
# capture coordinates for consistently node placement (from the `ggnet` package)
coords <- coord_place(net)

# plot some networks
# plain network
pdf('network.pdf')
    ggnet(net, direct = TRUE, title = 'Simple Network Graph', coords = coords)
dev.off()
pdf('network_lab.pdf')
    ggnet(net, direct = TRUE, title = 'Simple Network Graph (Labeled)', coords = coords,
          names = 'vertex.names')
dev.off()

# network with gender of individuals
pdf('shape_network.pdf')
    ggnet(net, direct = TRUE, shape = 'gender', coords = coords, legend = TRUE,
          title = 'Network Graph with Gender')
dev.off()

# network with gender and age of individuals
pdf('shape_color_network.pdf')
    ggnet(net, direct = TRUE, shape = 'gender', color = 'age', coords = coords,
          gradient = TRUE, legend = TRUE, title = 'Network Graph with Gender and Age')
dev.off()


# ergm
# take a quick pass to get better starting parameters
ergm_start <- ergm(net ~ edges + mutual + twopath + gwidegree(2) +
                   gwodegree(2) + gwesp(log(2)) + ctriple +
                   nodematch('gender'), control = control.ergm(MCMLE.maxit = 8))

# save parameters for a more in-depth pass
params <- enformulate.curved(ergm_start)

# re-estimate ergm with better starting parameters and greater control over MCMC
ergm_final <- ergm(params$formula,
                   control = control.ergm(init = params$theta,
                                          MCMLE.maxit = 20, MCMC.burnin = 100000,
                                          MCMC.interval = 1000,
                                          MCMC.samplesize = 15000))

# view results
summary(ergm_final)


## beer network
beer <- read.csv('untappd_network.csv', header = TRUE, sep = ',')

# convert to from two-mode edgelist (user-to-beer) to a one-mode matrix (user-to-user)
beermat <- t(table(beer)) %*% table(beer)

# create a network object
beernet <- network(beermat, directed = FALSE)

# add tie strength as an edge attribute
beernet %e% 'tie.strength' <- beermat

# take a look at one-mode network; values represent number of common beers between users
beermat

# network statistics
gden(beernet)
degree(beernet, gmode = 'graph')

# visualize the network
beer_coords = coord_place(beernet)
pdf('beer_network.pdf')
    ggnet(beernet, names = 'vertex.names', coords = beer_coords)
dev.off()

pdf('beer_network_strength.pdf')
    ggnet(beernet, names = 'vertex.names', coords = beer_coords,
          edge.val = beernet %e% 'tie.strength')
dev.off()

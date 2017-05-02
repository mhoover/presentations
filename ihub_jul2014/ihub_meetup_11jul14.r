# network visualization for ihub presentation, 11jul14
# written by: matt hoover (matthew.a.hoover@gmail.com)

# libraries
if('ggnet' %in% installed.packages()) {
    library(ggnet)
} else {
    require(devtools)
    install_github('mhoover/ggnet/ggnet')
}
require(statnet)

# data
el <- attr <- list()
el_files <- list.files(pattern = '^n[1-3]*')
attr_files <- list.files(pattern = '^attr_*')
for(i in 1:length(el_files)) {
    el[[i]] <- read.csv(el_files[i], header = TRUE, sep = ',',
                        stringsAsFactors = FALSE)
}
for(i in 1:length(attr_files)) {
    attr[[i]] <- read.csv(attr_files[i], header = TRUE, sep = ',',
                          stringsAsFactors = FALSE)
}

# create network objects
net1 <- network(el[[1]])
net2 <- network(el[[2]])
net3 <- network(el[[3]])

# add attributes to objects
net1 %v% 'age' <- attr[[1]]$age
net1 %v% 'gender' <- attr[[1]]$gender
net2 %v% 'age' <- attr[[2]]$age
net2 %v% 'gender' <- attr[[2]]$gender
net3 %v% 'age' <- attr[[3]]$age
net3 %v% 'gender' <- attr[[3]]$gender

# basic example of gplot
pdf('gplot_v01.pdf')
	gplot(net1)
dev.off()

# basics of network storage
net2
as.matrix(net2)
net2 %v% "gender"

# gplot visualizations
# basic, no attributes
pdf('gplot_basic.pdf')
	gplot(net2)
dev.off()

# with node color
pdf('gplot_color.pdf')
	gplot(net2, vertex.col = net2 %v% "age")
dev.off()

# adding shape is difficult -- need to specify the number of side
# need to make a new attribute
net2 %v% "gender.shape" <- ifelse(net2 %v% "gender" == "male",
	4, 3)

# check to ensure it worked correctly
table(net2 %v% "gender", net2 %v% "gender.shape")

# with node color and shape
pdf('gplot_color_shape.pdf')
	gplot(net2, vertex.col = net2 %v% "age",
		vertex.sides = net2 %v% "gender.shape")
dev.off()

# adding a legend and title is possible, but cumbersome
pdf('gplot_legend.pdf')
	gplot(net2, vertex.col = net2 %v% "age",
		vertex.sides = net2 %v% "gender.shape",
		main = "Social Network - V02")

	legend("bottomleft", c("6yrs", "7yrs", "8yrs", "9yrs", "10yrs", "11yrs",
		"female", "male"), pch = c(rep(4, 6), 0, 2), col = c("purple", "yellow",
		"grey", "black", "red", "green", "black", "black"), title = "Legend")
dev.off()

# ggnet visualizations
# basic, no attributes
pdf('ggnet_basic.pdf')
	ggnet(net2, direct = TRUE)
dev.off()

# with node color
pdf('ggnet_color.pdf')
	ggnet(net2, direct = TRUE, color = "age")
dev.off()

# with node color and shape
pdf('ggnet_color_shape.pdf')
	ggnet(net2, direct = TRUE, color = "age", shape = "gender")
dev.off()

# adding a legend and title is simple
pdf('ggnet_legend.pdf')
	ggnet(net2, direct = TRUE, color = "age", shape = "gender",
          title = "Social Network - V02", legend = TRUE)
dev.off()

# so, what's different?
# first, i can fix coordinates for nodes in the same network, but for different
#  types of ties

# plot playmate network
ggnet(net2, direct = TRUE, color = "age", shape = "gender",
	legend = TRUE)

# plot friendship network (same village)
pdf('ggnet_basic_friend.pdf')
	ggnet(net3, direct = TRUE)
dev.off()

# get coordinates for playmate network
v02.coords <- coord_place(net2)

# plot playmate, then friendship using same coordinates
pdf('ggnet_play_set.pdf')
	ggnet(net2, direct = TRUE, color = "age", shape = "gender", legend = TRUE,
          coords = v02.coords)
dev.off()
pdf('ggnet_friend_set.pdf')
	ggnet(net3, direct = TRUE, color = "age", shape = "gender", legend = TRUE,
          coords = v02.coords)
dev.off()

# second, we can use a variety of color schemes
# different palettes
pdf('ggnet_palette.pdf')
	ggnet(net2, direct = TRUE, color = "age", shape = "gender", legend = TRUE,
          palette = "Set2")
dev.off()

# or a gradient
pdf('ggnet_gradient.pdf')
	ggnet(net2, direct = TRUE, color = "age", shape = "gender", legend = TRUE,
          gradient = TRUE)
dev.off()

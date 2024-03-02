# Helper funcitons for
# support_network.ipynb


import pandas as pd
import numpy as np
import networkx as nx
import community as community_louvain
import time

from matplotlib import pyplot as plt 
from pyvis.network import Network


def make_support_table(url):
    '''
        Creates a tuple of pandas dataframes from String url:
        (support_table, individual_supports).

        The support_table is more readable but individual_supports formats
        the data better for making a network using the networkx package.
    '''


    support_table = pd.read_html(url)
    support_table = support_table[1]
    support_table = support_table.T
    support_table.columns = support_table.iloc[0]
    support_table = support_table.drop("Character")

    individual_supports = []
    for character in support_table.columns:
        for friend in support_table[character]:
            if friend != "--":
                individual_supports.append({"Source": character, "Target": friend})

    individual_supports = pd.DataFrame(individual_supports)
    return support_table, individual_supports




def grand_graph_draw(graph, graph_name):
    '''
        Determines a few attributes for the input nx.Graph() graph,
        and draws said graph. Returns nothing, although does create a 
        .html by the name of String graph_name, as such graph_name must include
        ".html" in the string.

    '''

    #Centrality measures to make the graph look nicer

    node_degree = dict(graph.degree)
    degree_dict = nx.degree_centrality(graph)
    betweenness_dict = nx.betweenness_centrality(graph)
    closeness_dict = nx.closeness_centrality(graph)

    nx.set_node_attributes(graph, node_degree, 'size')
    nx.set_node_attributes(graph, degree_dict, 'degree_centrality')
    nx.set_node_attributes(graph, betweenness_dict, 'betweenness_centrality')
    nx.set_node_attributes(graph, closeness_dict, 'closeness_centrality')

    communities = community_louvain.best_partition(graph)
    nx.set_node_attributes(graph, communities, 'group')


    # Drawing the graph in the notebook
    pos = nx.kamada_kawai_layout(graph)
    nx.draw(graph, with_labels=True, pos=pos)

    # Creating the .html output file
    net = Network(notebook=True, width="600px", height="600px",cdn_resources='remote')
    net.from_nx(graph)
    net.show(graph_name)
    return
# spdc network talk
# author: matt hoover (matthew.a.hoover at gmail.com)

# import all the prereqs
import os

import numpy as np
import pandas as pd

from untappd import *


# functions
def get_info_for_network(client, users, friends=False, limit=50):
    """ Gather information on beers and friends (optionally) for users.
    Inputs:
        client: Used to access the Untappd API
        users: A list of user names to gather data on
        friends: Boolean; whether friend data for user should be collected
        limit: Integer; indicates number of beers to return per call
    Outputs:
        beer_list: A list of tuples containing the beer name and beer id
        friends_list: A list of tuples containig the user name and user id
    """
    # Instantiate outputs
    beer_list = []
    friends_list = []
    for user in users:
        # Get user info for total number of beers checked-in
        u = client.info('user', 'info', user)
        tot_beers = u['response']['user']['stats']['total_beers']
        # Limit the number of beers to collect -- wards against rate limiting
        mx = tot_beers//limit + 1 if tot_beers<150 else 3
        # Make up to four calls per user to gather up to the last 200 beers checked-in
        for i in xrange(mx):
            b = client.info('user', 'beers', user, offset=i*50, limit=limit)
            beer_list.append([(x['beer']['beer_name'], x['beer']['bid']) for x in
                        b['response']['beers']['items']])
        beer_list = [x for y in beer_list for x in y]

        if friends:
            # Identify friends for user
            f = client.info('user', 'friends', user)
            friends_list.append([(x['user']['user_name'], x['user']['uid']) for x in
                                f['response']['items']])
    # Return outputs
    if friends:
        return beer_list, friends_list
    else:
        return beer_list


# set up api credentials (note: this assumes you have a key/secret for the untappd
# api -- https://untappd.com/api/docs)
KEY = os.getenv('UNTAPPD_KEY')
SECRET = os.getenv('UNTAPPD_SECRET')
client = Untappd(KEY, SECRET)

# load seed user (myself)
seed_beers, seed_friends = get_info_for_network(client, ['hooverm2'], friends = True)

# load friends beers
friends_beers = get_info_for_network(client, [x[0] for x in seed_friends[0]])

# build an edgelist
tot_beers = [len(x) for x in friends_beers]
friend_ids = [[x[1]] for y in seed_friends for x in y]
el = pd.DataFrame({
    'snd': [x for y in [a*b for a, b in zip(tot_beers, friend_ids)] for x in y],
    'rec': [x[1] for y in friends_beers for x in y],
})

# add in seed user
u = client.info('user', 'info', 'hooverm2')
seed_id = [u['response']['user']['uid']]
el = el.append(pd.DataFrame({
    'snd': len(seed_beers) * seed_id,
    'rec': [x[1] for x in seed_beers],
}))

# write data to csv
el.to_csv('untappd_network.csv', index=False)

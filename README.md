# Secret Sharing

A secret sharing Ruby library.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'secret_sharing'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install secret_sharing

## Usage

The Secret Sharing gem currently supports one algorithm: the sencod modified version (proposed by Ersoy et al. in in [Homomorphic extensions of CRT-based secret sharing](https://www.sciencedirect.com/science/article/pii/S0166218X20303012)) of the CRT-based secret sharing scheme introduced by Asmuth-Bloom in [A modular approach to key safeguarding](https://ieeexplore.ieee.org/abstract/document/1056651).

We have currently the class `CRTAsmuthBloomV2`. To initialize it, we need to pass the following parameters:

- `lambda_`: the bit length of the secret prime moduli.
- `threshold`: the recovery threshold in which it is guaranteed to recover the secret for all possible values.
- `secrecy`: the secrecy threshold in which it is guaranteed that no information is revealed about the secret.
- `total_shares`: the total number of shares we want to create for any given secret.
- `k_add`: the provisioned number of additions we want to compute over shares.
- `k_add`: the provisioned number of multiplicaitons we want to compute over shares.

```ruby
params = { lambda_: 64, threshold: 10, secrecy: 3, total_shares: 13, k_add: 5000, k_mul: 2 }
crtss = SecretSharing::CRTAsmuthBloomV2.new params
secret1 = 5
secret2 = 8
secret3 = 9
shares1 = crtss.compute_shares(secret1)
# => [[0, 4185685952388161215], [1, 7431082072249155627], [2, 3172867207673420707], [3, 14094855932661978905], [4, 8449128283552032507], [5, 7274923078167548868], [6, 3443672123003372167], [7, 3449028625755130838], [8, 5794221801968596287], [9, 3328886357835317095], [10, 7488573194762652917], [11, 8211719263601562780], [12, 12709118192143848454]]
shares2 = crtss.compute_shares(secret2)
# => [[0, 2233143134937563130], [1, 10799196764783177850], [2, 3895399176949806798], [3, 1198864688298180029], [4, 10749884548017217271], [5, 8208674321670086887], [6, 2822739185939232463], [7, 6792525158886356123], [8, 11182441441011760155], [9, 5065252015479538675], [10, 14231070486785344674], [11, 12955329422395114581], [12, 13444354079541844356]]
shares3 = crtss.compute_shares(secret3)
# => [[0, 8784211624348791413], [1, 3173871378881529520], [2, 13248531955944997083], [3, 1782634630778360250], [4, 13054421101338573568], [5, 12464404777826322232], [6, 10309434923908541341], [7, 11837628883332260554], [8, 7022273320911219172], [9, 2554741791512322214], [10, 11331979459726025879], [11, 5610455238685743922], [12, 3003841353993251584]]
```

With the shares created, we can compute basic arithmetic:

```ruby
shares1_add_shares2 = SecretSharing::CRTAsmuthBloomV2.add(shares1, shares2)
# => [[0, 6418829087325724345], [1, 18230278837032333477], [2, 7068266384623227505], [3, 15293720620960158934], [4, 19199012831569249778], [5, 15483597399837635755], [6, 6266411308942604630], [7, 10241553784641486961], [8, 16976663242980356442], [9, 8394138373314855770], [10, 21719643681547997591], [11, 21167048685996677361], [12, 26153472271685692810]]
shares1_mul_shares2 = SecretSharing::CRTAsmuthBloomV2.mul(shares1, shares2)
# => [[0, 9347235849580217942880423213680002950], [1, 80249717473471354529348429396269261950], [2, 12359584309342074742148630183422566186], [3, 16897825064318556900157377557090288245], [4, 90827153579571227732364682022273828397], [5, 59717474263879064686877969113378493916], [6, 9720588245128167152782160092717057321], [7, 23427613714160960605536958120927421074], [8, 64793545996747467446843059564467544485], [9, 16861648333327680706874620252941149125], [10, 106570412980118630776546521824476514058], [11, 106385528184186069985041673188764895180], [12, 170865885013928618679442811690919225624]]
shares1_add_shares2_add_shares1_mul_shares2 = SecretSharing::CRTAsmuthBloomV2.add(shares1_add_shares2, shares1_mul_shares2)
# => [[0, 9347235849580217949299252301005727295], [1, 80249717473471354547578708233301595427], [2, 12359584309342074749216896568045793691], [3, 16897825064318556915451098178050447179], [4, 90827153579571227751563694853843078175], [5, 59717474263879064702361566513216129671], [6, 9720588245128167159048571401659661951], [7, 23427613714160960615778511905568908035], [8, 64793545996747467463819722807447900927], [9, 16861648333327680715268758626256004895], [10, 106570412980118630798266165506024511649], [11, 106385528184186070006208721874761572541], [12, 170865885013928618705596283962604918434]]
```

In order to recover the associated secrets with the shares we just generated via basic arithmetic computations, we select a number of shares for reconstruction (in any random order). It could be the total number of shares or a smaller number. We will choose the exact number of the recovery threshold:

```ruby
selected_shares1_add_shares2 = shares1_add_shares2.sample(params[:threshold])
# => [[10, 21719643681547997591], [0, 6418829087325724345], [9, 8394138373314855770], [6, 6266411308942604630], [1, 18230278837032333477], [7, 10241553784641486961], [11, 21167048685996677361], [5, 15483597399837635755], [8, 16976663242980356442], [12, 26153472271685692810]]
selected_shares1_mul_shares2 = shares1_mul_shares2.sample(params[:threshold])
# => [[5, 59717474263879064686877969113378493916], [1, 80249717473471354529348429396269261950], [12, 170865885013928618679442811690919225624], [7, 23427613714160960605536958120927421074], [6, 9720588245128167152782160092717057321], [0, 9347235849580217942880423213680002950], [3, 16897825064318556900157377557090288245], [9, 16861648333327680706874620252941149125], [2, 12359584309342074742148630183422566186], [4, 90827153579571227732364682022273828397]]
selected_shares1_add_shares2_add_shares1_mul_shares2 = shares1_add_shares2_add_shares1_mul_shares2.sample(params[:threshold])
# => [[11, 106385528184186070006208721874761572541], [6, 9720588245128167159048571401659661951], [2, 12359584309342074749216896568045793691], [4, 90827153579571227751563694853843078175], [12, 170865885013928618705596283962604918434], [7, 23427613714160960615778511905568908035], [9, 16861648333327680715268758626256004895], [5, 59717474263879064702361566513216129671], [10, 106570412980118630798266165506024511649], [0, 9347235849580217949299252301005727295]]
```

Finally, we reconstruct the secrets:

```ruby
crtss.reconstruct_secret(selected_shares1_add_shares2)
# => 13 
crtss.reconstruct_secret(selected_shares1_mul_shares2)
# => 40
crtss.reconstruct_secret(selected_shares1_add_shares2_add_shares1_mul_shares2)
# => 53
```

and we can check that 5 + 8 = 13, 5 * 8 = 40, and 13 + 40 = 53.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davidwilliam/secret_sharing.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

# Sharing

A secret sharing Ruby library.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sharing'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install sharing
    
# Supported Secret Sharing Schemes

Secret Sharing currently supports two schemes:

- A first version of the Shamir's secret sharing
- The second of two modified versions of the CRT-based Asmuth-Bloom scheme proposed by Ersoy et al.

# Usage

## Shamir's Secret Sharing V1

The Shamir's secret sharing v1 scheme is based on the work of Adi Shamir in [How to Share a Secret](https://web.mit.edu/6.857/OldStuff/Fall03/ref/Shamir-HowToShareASecret.pdf).

### n-out-of-n Shamir Secret Sharing

Let's consider the followin setup:

```ruby
secret1 = 22
secret2 = 36
scalar = 2
params = {total_shares: 5, threshold: 5, lambda_: 16}
sss = Sharing::Polynomial::Shamir::V1.new params
# => #<Sharing::Polynomial::Shamir::V1:0x0000000114090618 @lambda_=16, @p=63719, @threshold=3, @total_shares=5>
```

We generate shares as follows:

```ruby
shares1 = sss.create_shares(secret1)
# => [[1, 17038], [2, 51463], [3, 24539], [4, 33770], [5, 34327]]
shares2 = sss.create_shares(secret2)
# => [[1, 26584], [2, 37554], [3, 53948], [4, 45589], [5, 58559]]
scalar = 2
```

We reconstruct the secrets as follows:

```ruby
reconstructed_secret1 = sss.reconstruct_secret(shares1)
# => (22/1)
reconstructed_secret2 = sss.reconstruct_secret(shares2)
# => (36/1)
```

We can compute linear functions without requiring communication between the share holders: 

```ruby
shares1_add_shares2 = Sharing::Polynomial::Shamir::V1.add(shares1, shares2, sss.p)
# => [[1, 43622], [2, 25298], [3, 14768], [4, 15640], [5, 29167]]
shares2_sub_shares1 = Sharing::Polynomial::Shamir::V1.sub(shares2, shares1, sss.p)
# => [[1, 9546], [2, 49810], [3, 29409], [4, 11819], [5, 24232]]
shares1_smul_scalar = Sharing::Polynomial::Shamir::V1.smul(shares1, scalar, sss.p)
# => [[1, 34076], [2, 39207], [3, 49078], [4, 3821], [5, 4935]]
shares1_sdiv_scalar = Sharing::Polynomial::Shamir::V1.sdiv(shares1, scalar, sss.p)
# => [[1, 8519], [2, 57591], [3, 44129], [4, 16885], [5, 49023]]
```

and we can check that:

```ruby
sss.reconstruct_secret(shares1_add_shares2)
# => (58/1)
sss.reconstruct_secret(shares2_sub_shares1)
# => (14/1)
sss.reconstruct_secret(shares1_smul_scalar)
# => (44/1)
sss.reconstruct_secret(shares1_sdiv_scalar)
# => (11/1)
```

### Using Hensel Codes

The gem Secret Sharing takes advantage of the gem [Hensel Codes](https://github.com/davidwilliam/hensel_code) for homomorphically encoding rational numbers as integers in order to compute over the integers and yet obtain results over the rationals.

As most (if not all) of secret sharing schemes over finite fields `F_p` for `p > 2`, the secret inputs are naturally required to be positive integers in `F_p`. In this way, if we compute subtraction and we end up with a result that is negative, the reconstruction will fail (provided we don't have any econding in place). Same will occur if we compute a scalar division involving a scalar that is not a divisor of the corresponding secret. For addressing this and many other arithmetic problems, we can use Hensel codes to allow secret inputs to be positive and negative rational numbers.

```ruby
rational_secret1 = Rational(2,3)
# => 2/3
rational_secret2 = Rational(-5,7)
# => -5/7
scalar = 5
# => 5
params = {total_shares: 5, threshold: 5, lambda_: 32}
# => {:total_shares=>5, :threshold=>5, :lambda_=>32}
sss = Sharing::Polynomial::Shamir::V1.new params
# => #<Sharing::Polynomial::Shamir::V1:0x0000000103065cd0 @lambda_=32, @total_shares=5, @threshold=5, @p=4151995223>
```

We compute the Hensel codes for the secrets:

```ruby
secret1 = HenselCode::TruncatedFinitePadicExpansion.new(sss.p, 1, rational_secret1).hensel_code
# => 2767996816
secret2 = HenselCode::TruncatedFinitePadicExpansion.new(sss.p, 1, rational_secret2).hensel_code
# => 593142174
```

Then, we create the shares:

```ruby
shares1 = sss.create_shares(secret1)
# => [[1, 1788895381], [2, 1795799163], [3, 3852643947], [4, 58410522], [5, 2611091242]]
shares2 = sss.create_shares(secret2)
# => [[1, 2523224758], [2, 2966680092], [3, 3722500411], [4, 3217222534], [5, 656923087]]
```

Now we can compute all the available linear computations as before:

```ruby
shares1_add_shares2 = Sharing::Polynomial::Shamir::V1.add(shares1, shares2, sss.p)
# => [[1, 160124916], [2, 610484032], [3, 3423149135], [4, 3275633056], [5, 3268014329]]
shares1_sub_shares2 = Sharing::Polynomial::Shamir::V1.sub(shares1, shares2, sss.p)
# => [[1, 3417665846], [2, 2981114294], [3, 130143536], [4, 993183211], [5, 1954168155]]
shares1_smul_scalar = Sharing::Polynomial::Shamir::V1.smul(shares1, scalar, sss.p)
# => [[1, 640486459], [2, 675005369], [3, 2655238843], [4, 292052610], [5, 599470541]]
shares1_sdiv_scalar = Sharing::Polynomial::Shamir::V1.sdiv(shares1, scalar, sss.p)
# => [[1, 2848976210], [2, 3680756011], [3, 1600927834], [4, 842081149], [5, 1352617293]]
```

We reconstruct the secrets:

```ruby
reconstruct_secret1_add_secret2 = sss.reconstruct_secret(shares1_add_shares2)
# => 3361138990/1
reconstruct_secret1_sub_secret2 = sss.reconstruct_secret(shares1_sub_shares2)
# => 2174854642/1
reconstruct_shares1_smul_scalar = sss.reconstruct_secret(shares1_smul_scalar)
# => 1383998411/1
reconstruct_shares1_sdiv_scalar = sss.reconstruct_secret(shares1_sdiv_scalar)
# => 3044796497/1
```

and we can check that:

```ruby
HenselCode::TruncatedFinitePadicExpansion.new(sss.p, 1, reconstructed_secret1_add_secret2).to_r
# => -1/21
HenselCode::TruncatedFinitePadicExpansion.new(sss.p, 1, reconstructed_secret1_sub_secret2).to_r
# => 29/21
HenselCode::TruncatedFinitePadicExpansion.new(sss.p, 1, reconstructed_shares1_smul_scalar).to_r
# => 10/3
HenselCode::TruncatedFinitePadicExpansion.new(sss.p, 1, reconstructed_shares1_sdiv_scalar).to_r
# => 2/15
```

### t-out-of-n Secret Sharing

Now we defined a threshold value that is less than the total number of shares:

```ruby
params = {total_shares: 5, threshold: 3, lambda_: 16}
# => {:total_shares=>5, :threshold=>3, :lambda_=>16}
sss = Sharing::Polynomial::Shamir::V1.new params
# => #<Sharing::Polynomial::Shamir::V1:0x000000010b046e90 @lambda_=16, @p=61343, @threshold=3, @total_shares=5>
secret = 25
# => 25
shares = sss.create_shares(secret)
# => [[1, 54707], [2, 50401], [3, 48450], [4, 48854], [5, 51613]]
selected_shares = shares.sample(3)
reconstructed_secret = sss.reconstruct_secret(selected_shares)
# => 25
```

Everything else works the sabe as before except the fact that only `3` shares are required to reconstruct the secret.

## Asmuth-Bloom V2

The Asmuth-Bloom V2 was proposed by Ersoy et al. in in [Homomorphic extensions of CRT-based secret sharing](https://www.sciencedirect.com/science/article/pii/S0166218X20303012)). The reference is a CRT-based secret sharing scheme introduced by Asmuth-Bloom in [A modular approach to key safeguarding](https://ieeexplore.ieee.org/abstract/document/1056651).

We have currently the class `Sharing::CRT::AsmuthBloom::V2`. To initialize it, we need to pass the following parameters:

- `lambda_`: the bit length of the secret prime moduli.
- `threshold`: the recovery threshold in which it is guaranteed to recover the secret for all possible values.
- `secrecy`: the secrecy threshold in which it is guaranteed that no information is revealed about the secret.
- `total_shares`: the total number of shares we want to create for any given secret.
- `k_add`: the provisioned number of additions we want to compute over shares.
- `k_add`: the provisioned number of multiplicaitons we want to compute over shares.

```ruby
params = { lambda_: 64, threshold: 10, secrecy: 3, total_shares: 13, k_add: 5000, k_mul: 2 }
crtss = Sharing::CRTAsmuthBloomV2.new params
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
shares1_add_shares2 = Sharing::CRTAsmuthBloomV2.add(shares1, shares2)
# => [[0, 6418829087325724345], [1, 18230278837032333477], [2, 7068266384623227505], [3, 15293720620960158934], [4, 19199012831569249778], [5, 15483597399837635755], [6, 6266411308942604630], [7, 10241553784641486961], [8, 16976663242980356442], [9, 8394138373314855770], [10, 21719643681547997591], [11, 21167048685996677361], [12, 26153472271685692810]]
shares1_mul_shares2 = Sharing::CRTAsmuthBloomV2.mul(shares1, shares2)
# => [[0, 9347235849580217942880423213680002950], [1, 80249717473471354529348429396269261950], [2, 12359584309342074742148630183422566186], [3, 16897825064318556900157377557090288245], [4, 90827153579571227732364682022273828397], [5, 59717474263879064686877969113378493916], [6, 9720588245128167152782160092717057321], [7, 23427613714160960605536958120927421074], [8, 64793545996747467446843059564467544485], [9, 16861648333327680706874620252941149125], [10, 106570412980118630776546521824476514058], [11, 106385528184186069985041673188764895180], [12, 170865885013928618679442811690919225624]]
shares1_add_shares2_add_shares1_mul_shares2 = Sharing::CRTAsmuthBloomV2.add(shares1_add_shares2, shares1_mul_shares2)
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

Bug reports and pull requests are welcome on GitHub at https://github.com/davidwilliam/sharing.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

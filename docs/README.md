# ELJABR

Custom classes for working with algebraic expressions.

# DEPS

- [avtomat](https://github.com/Liebranca/avtomat)

# SETUP

```bash
cd  $ARPATH
git clone https://github.com/Liebranca/eljabr
eljabr/install.pl
eljabr/avto
```

That will build the project into `$ARPATH/lib/eljabr/`.

# CHANGELOG

### v0.00.5b

- Fractional terms are now clamped to four decimals.

- Added `*::con::EPS` to do "loose" comparison between fractional terms rather than unviable strict equality.

- `*::expr::(combine|distribute)` initial support for multiplying and adding fractions.

- `*::plug` now correctly uses the first element in history array for solving.

- Added `*::check` for plugging and solving expressions.

### v0.00.4b

- Added `*::con::FRAC_RE` to detect terms with fractions.

- Added initial *barebones* support for clearing fractions with `*::over(1/x)`.

- `*::histc` no longer gets confused with fractional constants.

### v0.00.3b

- `*::expr` methods no longer run automatic `*::expr::update`.

- Running of `*::update` moved to `*::expr` wraps, ran by container.

- Wrapped `*::expr::update` adds a comment detailing the edit and pushes to a history array.

- `*::hist` method added for printing out container `*::update` history.

- `*::histc` for doing the same, but with colors ;>

### v0.00.2b

- Added `*::expr::over` method for term division as well as matching container wrapper.

- Simplified term-value extraction with `*::expr` guts `*::expr::_tex` and `*::expr::_texv` methods.

- `*::con::VAR` re now accounts for the variable multiplier.

### v0.00.1b

- Turned a literal scratch buffer into a repo.

CURRENTDATE=`date +"%Y-%m-%d"`

help: ## Display this help screen
	@grep -h \
		-E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

test-ci: fmt clippy test ## Run all the CI checks locally (in your actual toolchain)

test-all: test-ci ## Run all available tests

build-release: ## Check build in release mode
	@cargo build --release

run-supper:
	@cargo run --release --bin prove -- --params zkevm/test_params --seed zkevm/test_seed --trace ${PWD}/traces-data --super true

run-empty:
	@cargo run --release --bin prove -- --params zkevm/test_params --seed zkevm/test_seed --trace ${PWD}/zkevm/tests/traces/empty.json --evm true

convert:
	@cargo run --bin convert -- --params zkevm/test_params --from-format=Processed --to-format=RawBytes

fmt: ## Check whether the code is formated correctly
	@cargo fmt --all -- --check

clippy: ## Run clippy checks over all workspace members
	@cargo check --all-features
	@cargo clippy --release --features prove_verify -- -D warnings

test: ## Run tests for all the workspace members
	@cargo test --release --all

bridge-test:
	cargo build --release
	./target/release/prove --params=./test_params --seed=./test_seed --trace=zkevm/tests/traces/bridge --agg=true

test-super-trace: ## test super circuit with real trace
	CIRCUIT=super cargo test --features prove_verify --release test_prove_verify

mock:
	@cargo test --features prove_verify --release test_mock_prove -- --exact --nocapture

mock-debug:
	@cargo test --features prove_verify test_mock_prove -- --exact --nocapture

test-agg:
	@cargo test --features prove_verify --release test_agg

rows:
	@cargo test --features prove_verify --release estimate_circuit_rows

.PHONY: help fmt clippy test test-ci test-all

use clap::Parser;
use halo2_proofs::SerdeFormat;
use log::info;
use rand::SeedableRng;
use rand_xorshift::XorShiftRng;
use std::collections::HashMap;
use std::fs;
use std::fs::File;
use std::io::Write;
use std::path::PathBuf;
use std::time::Instant;
use zkevm::{
    circuit::{EvmCircuit, StateCircuit, AGG_DEGREE, DEGREE},
    prover::Prover,
    utils::{
        convert_params, get_block_trace_from_file, load_or_create_params, load_or_create_seed,
    },
};

#[derive(Parser, Debug)]
#[clap(author, version, about, long_about = None)]
struct Args {
    /// Get params and write into file.
    #[clap(short, long = "params")]
    params_path: Option<String>,
    #[clap(short, long = "degree")]
    degree: Option<usize>,
    #[clap(long = "from-format")]
    from_format: String,
    #[clap(long = "to-format")]
    to_format: String,
}

fn main() {
    dotenv::dotenv().ok();
    env_logger::init();

    let args = Args::parse();

    let from_format = args.from_format.parse::<SerdeFormat>().unwrap();
    let to_format = args.to_format.parse::<SerdeFormat>().unwrap();

    if from_format == to_format {
        return;
    }

    convert_params(
        &args.params_path.clone().unwrap(),
        args.degree.unwrap_or(*DEGREE),
        from_format,
        to_format,
    )
    .unwrap();
}

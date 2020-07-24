# Signal Enhancement for Magnetic Navigation Challenge Problem

This is a repository for the signal enhancement for magnetic navigation (MagNav) challenge problem. The high-level goal is to take magnetometer (magnetic field) readings from within the cockpit and remove the aircraft magnetic noise to yield a clean magnetic signal. A detailed description of the challenge problem can be found [here](https://arxiv.org/pdf/2007.12158.pdf).

## Starter Code

A basic set of starter Julia code files have been provided within the `src` folder. This code is largely based on work done by [Major Canciani](https://apps.dtic.mil/dtic/tr/fulltext/u2/1017870.pdf). A sample run file is located within the `runs` folder, which includes downloading the flight data via artifact (`Artifacts.toml`). Details of the flight data are described in the readme files within the `readmes` folder. The flight data can also be directly downloaded from [here](https://www.dropbox.com/sh/dl/x37yr72x5a5nbz0/AADBt8ioU4Lm7JgEMQvPD7gxa/flight_data.tar.gz).

## Team Members

The MagNav team is part of the MIT-Air Force Artficial Intelligence Accelerator, a joint
collaboration between the US Air Force, MIT CSAIL, and MIT Lincoln Laboratory. Team members include:

[MIT Julia Lab](https://julia.mit.edu/)
- Albert R. Gnadt (AeroAstro Graduate Student)
- Chris Rackauckas (Applied Mathematics Instructor)
- Alan Edelman (Applied Mathematics Professor)

[MIT Lincoln Laboratory](https://www.ll.mit.edu/)
- Joseph Belarge (Group 46)
- Lauren Conger
- Peter Morales (Group 01)
- Michael F. O'Keeffe (Group 89)
- Jonathan Taylor (Group 52)

[Air Force Institute of Technology](https://www.afit.edu/)
- Major Aaron Canciani
- Major Joseph Curro

Air Force @ MIT
- Major David Jacobs

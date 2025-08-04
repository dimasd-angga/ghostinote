# Research notes

Short notes captured while learning the AppKit / capture pipeline.
- Tested: launching while another full-screen Space is active - overlay appears once we add .fullScreenAuxiliary to collectionBehavior.
- Observation: hiding the overlay via orderOut() and re-showing it preserves the sharingType setting. No need to re-apply.

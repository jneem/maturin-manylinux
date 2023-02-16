use ffmpeg_sys_next::avcodec_register_all;
use pyo3::prelude::*;

#[pymodule]
#[pyo3(name = "bug_report")]
fn mymodule(_py: Python, _m: &PyModule) -> PyResult<()> {
    unsafe {
        avcodec_register_all();
    }
    Ok(())
}

use libc::c_char;
use std::ffi::CStr;
use std::ffi::CString;

use recess_algorithm::prelude::*;

#[no_mangle]
pub extern "C" fn call(
    adults_json: *const c_char,
    dates_json: *const c_char,
    config_json: *const c_char,
) -> *mut c_char {
    let adults_json_str = unsafe {
        assert!(!adults_json.is_null());
        CStr::from_ptr(adults_json)
    };
    let dates_json_str = unsafe {
        assert!(!dates_json.is_null());
        CStr::from_ptr(dates_json)
    };
    let config_json_str = unsafe {
        assert!(!config_json.is_null());
        CStr::from_ptr(config_json)
    };

    let mut adults: Vec<Adult> = serde_json::from_str(adults_json_str.to_str().unwrap()).unwrap();

    let mut de = serde_json::Deserializer::from_str(dates_json_str.to_str().unwrap());
    let dates = serde_naive_dates::deserialize(&mut de).unwrap();

    let config: Config = serde_json::from_str(config_json_str.to_str().unwrap()).unwrap();

    env_logger::init();

    adults.iter().for_each(|adult| log::trace!("{:?}", adult));
    log::trace!("{:?}\n", dates);
    log::trace!("{:?}\n", config);

    recess_algorithm::call(&mut adults, &dates, &config);

    let output = serde_json::to_string(&adults).unwrap();
    let c_str_output = CString::new(output).unwrap();
    c_str_output.into_raw()
}

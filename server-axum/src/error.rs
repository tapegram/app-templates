use axum::{
    http::StatusCode,
    response::{IntoResponse, Response},
};

//Idk if we will use this but can stay here for now
pub type Result<T> = core::result::Result<T, Error>;

#[derive(Debug)]
pub enum Error {
    //types of errors go here
    GetUsersError,
    PostUserError
}

// region: error boilerplate
impl std::fmt::Display for Error {
    fn fmt(&self, fmt: &mut std::fmt::Formatter) -> core::result::Result<(), std::fmt::Error> {
        write!(fmt, "{self:?}")
    }
}

impl std::error::Error for Error {}
// endregion: error boilerplate

impl IntoResponse for Error {
    fn into_response(self) -> Response {
        println!("->> {:<12} - {self:?}", "INTO_RESPONSE");
        (StatusCode::INTERNAL_SERVER_ERROR, "UNHANDLED_CLIENT_ERROR").into_response()
    }
}
// Or this one that implements the same thing from the other way around
// impl From<Error> for Response {
//     fn from(error: Error) -> Self {
//         println!("->> {:<12} - {self:?}", "INTO_RESPONSE");
//         (StatusCode::INTERNAL_SERVER_ERROR, "UNHANDLED_CLIENT_ERROR").into_response()
//     }
// }
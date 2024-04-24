isolated function loadDirectors(readonly & anydata[] ids) returns DirectorRecord[]|error {
    string[] keys = check ids.ensureType();
    stream<DirectorRecord, error?> directorStream = check datasource->getDirectorsById(keys);
    DirectorRecord[] directors = check from DirectorRecord director in directorStream
        select director;

    DirectorRecord[] result = [];
    foreach [int, string][i, id] in keys.enumerate() {
        foreach DirectorRecord director in directors {
            if id == director.id {
                result[i] = director;
                break;
            }
        }
    }
    return result;
}

isolated function loadMovies(readonly & anydata[] ids) returns MovieRecord[][]|error {
    string[] keys = check ids.ensureType();
    stream<MoviesOfDirector, error?> movieStream = check datasource->getMoviesByDirectorId(keys);
    MoviesOfDirector[] moviesWithDirectorId = check from MoviesOfDirector movieSet in movieStream
        select movieSet;
    MovieRecord[][] result = [];

    foreach [int, string] [i, key] in keys.enumerate() {
        MovieRecord[] movies = [];
        foreach MoviesOfDirector movieSet in moviesWithDirectorId {
            if key == movieSet._id {
                movies = movieSet.movies;
                break;
            }
        }
        result[i] = movies;
    }
    return result;
}

isolated function validateUserRole(UserRecord user, string expectedRole) returns error? {
    if user.roles.indexOf(expectedRole) is int {
        return;
    }
    return error("Unauthorized access to the resource");
}

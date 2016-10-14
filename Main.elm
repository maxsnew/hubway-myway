import Html exposing (Html, button, div, text)
import Html.App as App
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode
import Json.Decode exposing ((:=), at, Decoder)
import Task

-- | Displays the current bike capacity for the hubway stations I care about

main =
  App.program { init = init, view = view, update = update , subscriptions = \_ -> Sub.none }


-- MODEL

type alias StationStatus = { station_id : String
                           , num_bikes_available : Int
                           -- , num_bikes_disabled : Int
                           , num_docks_available : Int
                           -- , num_docks_disabled : Int
                           -- , is_installed : Boolean
                           -- , is_renting : Boolean
                           -- , is_returning : Boolean
                           -- , last_reported : String -- Time
                           -- , eightd_has_available_keys : Boolean
                           }
type alias Model = Result Http.Error (List StationStatus)

mk_station_status : String -> Int -> Int -> StationStatus
mk_station_status id bikes docks =
    { station_id = id
    , num_bikes_available = bikes
    , num_docks_available  = docks
    }

station_status : Decoder StationStatus
station_status = Decode.object3 mk_station_status
                 ("station_id" := Decode.string)
                 ("num_bikes_available" := Decode.int)
                 ("num_docks_available" := Decode.int)

model_decoder : Decoder (List StationStatus)
model_decoder = at ["data", "stations"] (Decode.list station_status)

fetch : Cmd Msg
fetch = Task.perform  Err Ok <|
        Http.get model_decoder "https://gbfs.thehubway.com/gbfs/en/station_status.json"
    
init : (Model, Cmd Msg)
init = (Ok [], fetch)

-- UPDATE

type alias Msg = Model

update : Msg -> Model -> (Model, Cmd Msg)
update new_info old_info = (new_info, Cmd.none)

-- VIEW

view : Model -> Html Msg
view model =
  div []
    [ text (toString model)
    ]

# state-of-states

This application is intended to provide a dashboard of state and metropolitan level economic data, primarily relying on data from the Bureau of Labor Statistics Current Employment Statistics - State and Area program. 

This application requires a registered API key from the BLS, which can be requested at the following site: https://data.bls.gov/registrationEngine/.

The application is still very much in development and should not be considered stable or functional. 

The programs must be run in the following order: 
scrape-series-id.R
bls-api-pull.R
playing-with-leaflet.R
Then run the app from ui.R or server.R

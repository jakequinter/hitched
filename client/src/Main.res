%%raw("import './index.css'")

let client = ReactQuery.Provider.createClient()

switch ReactDOM.querySelector("#root") {
| Some(domElement) =>
  ReactDOM.Client.createRoot(domElement)->ReactDOM.Client.Root.render(
    <React.StrictMode>
      <ReactQuery.Provider client={client}>
        <AuthContext.Provider>
          <App />
        </AuthContext.Provider>
      </ReactQuery.Provider>
    </React.StrictMode>,
  )
| None => ()
}

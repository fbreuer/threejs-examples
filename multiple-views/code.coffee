
# The Mathematics

gcd = (a,b,depth=0) -> 
  switch
    when a > b  then gcd(a-b,b,depth+1)
    when a < b  then gcd(a,b-a,depth+1)
    when a == b then [a, depth]
    else "error"

canonicalize = (a,b) ->
  [g,d] = gcd(a,b)
  [a/g, b/g]


# Helper Functions for Creating Three.js Objects

remove_duplicates = (arr) ->
  output = {}
  output[arr[key]] = arr[key] for key in [0...arr.length]
  value for key, value of output

gcd_geometry = (boxsize=10) ->
  M = boxsize
  S = []
  for a in [1..M]
    for b in [1..M]
      S.push(canonicalize(a,b))
  S = remove_duplicates(S)
  console.log(S)
  pair2line = (p,q) ->
    l = Math.min(M/p,M/q)
    [g,depth] = gcd(p,q)
    { from: [p,q,1], to: [l*p,l*q,l], color: depth/M }          
  ( pair2line(p,q) for [p,q] in S )

drawline = (from,to,material) ->
  geometry = new THREE.Geometry()
  geometry.vertices[0] = new THREE.Vector3( from[0], from[1], from[2] )
  geometry.vertices[1] = new THREE.Vector3( to[0], to[1], to[2] )
  new THREE.Line(geometry, material, THREE.LineStrip)

drawcube = (M,material) ->
  group = new THREE.Object3D()
  group.add(drawline(a,b,material)) for [a,b] in [ 
    [[0,0,0], [M,0,0]], 
    [[0,0,0], [0,M,0]],
    [[0,0,0], [0,0,M]],
    [[M,0,0], [M,0,M]],
    [[M,0,0], [M,M,0]],
    [[0,M,0], [0,M,M]],
    [[0,M,0], [M,M,0]],
    [[0,0,M], [M,0,M]],
    [[0,0,M], [0,M,M]],
    [[M,M,0], [M,M,M]],
    [[0,M,M], [M,M,M]],
    [[M,0,M], [M,M,M]] ]
  group


from_rgb = (triple) ->
  new THREE.Color().setRGB( triple[0], triple[1], triple[2] )

# Setup Three.js

init = (boxsize) ->
  renderer = new THREE.WebGLRenderer()
  renderer.setSize( window.innerWidth, window.innerHeight )
  document.body.appendChild( renderer.domElement )

  alpha = 1
  aspect = window.innerWidth / window.innerHeight

  camera = new THREE.PerspectiveCamera( 25, window.innerWidth / window.innerHeight, 1, 1000 )
  #camera = new THREE.OrthographicCamera( -alpha*boxsize*aspect, alpha*boxsize*aspect, alpha*boxsize, -alpha*boxsize, 1, 1000 );

  camera.position.z = 50

  scene = new THREE.Scene()

  group = new THREE.Object3D()

  group.add(drawcube(boxsize, new THREE.LineBasicMaterial( { color: 0x000000, linewidth: 2} )))

  for line in gcd_geometry(boxsize)
    color = new THREE.Color()
    color.setHSL(line.color, 0.8, 0.4)
    material = new THREE.LineBasicMaterial( { color: color, dashSize: 3, gapSize: 1, linewidth: 2} )
    group.add(drawline(line.from,line.to,material))

  scene.add(group)

  group.rotation.x = 3.1415 * (- 0.5 )
  group.position.x = -5
  group.position.y = -5

  render = () ->
    views = { left: {
        left: 0,
        bottom: 0,
        width: 0.67,
        height: 1,
        background: [0.5, 0.5, 0.7]
      }, bottom_right: {
        left: 0.67,
        bottom: 0,
        width: 0.33,
        height: 0.5,
        background: [0.5, 0.7, 0.5]
      }, top_right: {
        left: 0.67,
        bottom: 0.5,
        width: 0.33,
        height: 0.5,
        background: [0.7, 0.5, 0.5]
      }
    }

    render_view = (view, scene, camera) ->
      left = Math.floor( window.innerWidth * view.left )
      bottom = Math.floor( window.innerHeight * view.bottom )
      width = Math.floor( window.innerWidth * view.width )
      height = Math.floor( window.innerHeight * view.height )

      renderer.setSize(window.innerWidth, window.innerHeight)
      renderer.setViewport(left,bottom,width,height)
      renderer.setScissor(left,bottom,width,height)
      renderer.enableScissorTest(true)
      renderer.setClearColor(from_rgb(view.background))

      camera.aspect = width / height
      camera.updateProjectionMatrix()

      renderer.render( scene, camera )

    render_view(views.left, scene, camera)
    render_view(views.top_right, scene, camera)
    render_view(views.bottom_right, scene, camera)

  controls = new THREE.OrbitControls( camera )
  controls.addEventListener( 'change', render )

  render


# Main

render = init(10)

render()
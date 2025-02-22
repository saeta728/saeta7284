using UnityEngine;
using UnityEngine.UI;
using System.Collections;

public class TankGame : MonoBehaviour
{
    public GameObject playerTank;
    public Material usaTankMaterial;
    public Material germanyTankMaterial;
    public Light sceneLighting;
    public ParticleSystem explosionEffect;
    public ParticleSystem dustEffect;
    public GameObject reticle;
    public Color reticleGlowColor;
    public AudioSource rainSound;
    public Terrain gameMap;
    public Text usaPlayerList;
    public Text germanyPlayerList;
    public GameObject mapPreview;
    public GameObject winScreen;
    public GameObject loseScreen;
    public GameObject playButton;
    public float countdownTime = 60.0f;
    private int usaPlayers = 0;
    private int germanyPlayers = 0;
    private int maxPlayersPerTeam = 30;
    private float health = 100;
    private float moveSpeed = 5f;
    private float rotationSpeed = 100f;
    public GameObject projectile;
    public Transform firePoint;
    public AudioSource fireSound;
    
    void Start()
    {
        playButton.SetActive(true);
        winScreen.SetActive(false);
        loseScreen.SetActive(false);
    }
    
    public void StartGame()
    {
        playButton.SetActive(false);
        StartCoroutine(WaitForPlayers());
        rainSound.Play();
    }
    
    IEnumerator WaitForPlayers()
    {
        float timer = countdownTime;
        while (timer > 0)
        {
            usaPlayerList.text = "USA Players: " + usaPlayers + "/30";
            germanyPlayerList.text = "Germany Players: " + germanyPlayers + "/30";
            timer -= Time.deltaTime;
            yield return null;
        }
        AssignBotsIfNeeded();
    }
    
    void AssignBotsIfNeeded()
    {
        if (usaPlayers < maxPlayersPerTeam)
        {
            usaPlayers += maxPlayersPerTeam - usaPlayers;
        }
        
        if (germanyPlayers < maxPlayersPerTeam)
        {
            germanyPlayers += maxPlayersPerTeam - germanyPlayers;
        }
    }
    
    void Update()
    {
        MoveTank();
        RotateTurret();
        if (Input.GetMouseButtonDown(1) || Input.GetKeyDown(KeyCode.Space))
        {
            Fire();
        }
    }
    
    void MoveTank()
    {
        float move = Input.GetAxis("Vertical") * moveSpeed * Time.deltaTime;
        float rotate = Input.GetAxis("Horizontal") * rotationSpeed * Time.deltaTime;
        playerTank.transform.Translate(0, 0, move);
        playerTank.transform.Rotate(0, rotate, 0);
    }
    
    void RotateTurret()
    {
        Ray ray = Camera.main.ScreenPointToRay(Input.mousePosition);
        if (Physics.Raycast(ray, out RaycastHit hit))
        {
            playerTank.transform.LookAt(new Vector3(hit.point.x, playerTank.transform.position.y, hit.point.z));
        }
    }
    
    void Fire()
    {
        GameObject shot = Instantiate(projectile, firePoint.position, firePoint.rotation);
        shot.GetComponent<Rigidbody>().velocity = firePoint.forward * 50f;
        fireSound.Play();
    }
    
    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Projectile"))
        {
            health -= 30;
            if (health <= 0)
            {
                Explode();
            }
        }
        else if (collision.gameObject.CompareTag("Ground"))
        {
            dustEffect.Play();
        }
    }
    
    void Explode()
    {
        explosionEffect.transform.position = playerTank.transform.position;
        explosionEffect.Play();
        Destroy(playerTank);
        CheckGameOver();
    }
    
    void CheckGameOver()
    {
        if (usaPlayers == 0 || germanyPlayers == 0)
        {
            if (usaPlayers > 0)
            {
                winScreen.SetActive(true);
            }
            else
            {
                loseScreen.SetActive(true);
            }
        }
    }
}

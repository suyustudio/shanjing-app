.class Ll0/b$a;
.super Ljava/lang/Object;
.source "SourceFile"

# interfaces
.implements Li0/h$b;


# annotations
.annotation system Ldalvik/annotation/EnclosingMethod;
    value = Ll0/b;-><init>(Ll0/b$c;Li0/h;)V
.end annotation

.annotation system Ldalvik/annotation/InnerClass;
    accessFlags = 0x0
    name = null
.end annotation


# instance fields
.field final synthetic a:Ll0/b;


# direct methods
.method constructor <init>(Ll0/b;)V
    .locals 0

    iput-object p1, p0, Ll0/b$a;->a:Ll0/b;

    invoke-direct {p0}, Ljava/lang/Object;-><init>()V

    return-void
.end method


# virtual methods
.method public a(Ljava/lang/String;)V
    .locals 2

    iget-object v0, p0, Ll0/b$a;->a:Ll0/b;

    invoke-static {v0}, Ll0/b;->b(Ll0/b;)Ll0/b$c;

    move-result-object v0

    iget-object v1, p0, Ll0/b$a;->a:Ll0/b;

    invoke-static {v1, p1}, Ll0/b;->a(Ll0/b;Ljava/lang/String;)Landroid/view/PointerIcon;

    move-result-object p1

    invoke-interface {v0, p1}, Ll0/b$c;->setPointerIcon(Landroid/view/PointerIcon;)V

    return-void
.end method
